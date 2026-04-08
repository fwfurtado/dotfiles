function awsop --description "Execute AWS CLI using credentials from 1Password"
  argparse 'h/help' 'item=' 'vault=' -- $argv
  or return 1

  if set -q _flag_help
    echo "Usage: awsop [doctor] --item <item-name> [--vault <vault>] <aws args...>" >&2
    echo >&2
    echo "Executes 'aws' using credentials from 1Password." >&2
    echo >&2
    echo "Options:" >&2
    echo "  -h, --help           Show this help message" >&2
    echo "  --item <item-name>   1Password item name (default: \$AWS_OP_ITEM)" >&2
    echo "  --vault <vault>      1Password vault name (default: \$AWS_OP_VAULT or homelab)" >&2
    echo >&2
    echo "The 1Password item must have the following fields at the root level" >&2
    echo "(not inside any section):" >&2
    echo "  - access-key-id" >&2
    echo "  - secret-access-key" >&2
    echo "  - endpoint-url" >&2
    echo >&2
    echo "Requirements:" >&2
    echo "  - op   (1Password CLI)" >&2
    echo "  - jq   (JSON processor)" >&2
    echo "  - aws  (AWS CLI)" >&2
    echo >&2
    echo "Subcommands:" >&2
    echo "  doctor                Check if all required dependencies are installed" >&2
    echo >&2
    echo "Examples:" >&2
    echo "  awsop --item 'My Item Name' -- s3 ls s3://assets" >&2
    echo "  awsop --item 'My Item Name' --vault myvault s3 cp file.txt s3://bucket/" >&2
    echo "  awsop --item 'My Item Name' --vault myvault ec2 describe-instances" >&2
    echo "  awsop --item 'My Item Name' --vault myvault iam list-users" >&2
    echo "  awsop --item 'My Item Name' --vault myvault rds describe-db-instances" >&2
    echo "  awsop --item 'My Item Name' --vault myvault s3 ls s3://assets" >&2
    echo "  awsop --item 'My Item Name' --vault myvault s3 cp file.txt s3://bucket/" >&2
    echo "  awsop --item 'My Item Name' --vault myvault s3 ls s3://assets" >&2
    return 0
  end

  if test (count $argv) -ge 1; and test "$argv[1]" = doctor
    set -l ok true
    for cmd in op jq aws
      if command -v $cmd >/dev/null 2>&1
        echo "  ✓ $cmd found: $(command -v $cmd)"
      else
        echo "  ✗ $cmd not found"
        set ok false
      end
    end
    if test "$ok" = true
      echo ""
      echo "All dependencies are installed."
      return 0
    else
      echo ""
      echo "Some dependencies are missing." >&2
      return 1
    end
  end

  set -l item (set -q _flag_item; and echo $_flag_item; or echo "$AWS_OP_ITEM")
  set -l vault (set -q _flag_vault; and echo $_flag_vault; or echo "$AWS_OP_VAULT")

  if test -z "$item" -a -z "$vault"
    echo "Usage: awsop [doctor] --item <item-name> [--vault <vault>] <aws args...>" >&2
    echo "Set AWS_OP_ITEM and AWS_OP_VAULT in your environment or use --item and --vault. Run 'awsop --help' for more information." >&2
    return 1
  end

  if test -z "$item"
    echo "Usage: awsop [doctor] --item <item-name> [--vault <vault>] <aws args...>" >&2
    echo "Set AWS_OP_ITEM in your environment or use --item. Run 'awsop --help' for more information." >&2
    return 1
  end

  if test -z "$vault"
    echo "Usage: awsop [doctor] --item <item-name> [--vault <vault>] <aws args...>" >&2
    echo "Set AWS_OP_VAULT in your environment or use --vault. Run 'awsop --help' for more information." >&2
    return 1
  end

  if ! command -v op >/dev/null 2>&1
    echo "op not found. Run 'awsop doctor' to check dependencies." >&2
    return 1
  end

  if ! command -v jq >/dev/null 2>&1
    echo "jq not found. Run 'awsop doctor' to check dependencies." >&2
    return 1
  end

  if ! command -v aws >/dev/null 2>&1
    echo "aws not found. Run 'awsop doctor' to check dependencies." >&2
    return 1
  end

  set -l credentials (op item get --reveal --vault $vault $item --fields label=access-key-id,label=secret-access-key,label=endpoint-url --format json | jq -r '[ .[] | {key: .label, value: .value}  ] | from_entries')

  env \
    AWS_ACCESS_KEY_ID="$(echo $credentials | jq -r '."access-key-id"')" \
    AWS_SECRET_ACCESS_KEY="$(echo $credentials | jq -r '."secret-access-key"')" \
    AWS_REGION="garage" \
    aws --endpoint-url "$(echo $credentials | jq -r '."endpoint-url"')" $argv
end
