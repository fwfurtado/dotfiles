# Completions for awsop

# Disable file completions by default
complete -c awsop -f

# Subcommands
complete -c awsop -n "__fish_use_subcommand" -a "doctor" -d "Check if all required dependencies are installed"

# Flags
complete -c awsop -l item -r -d "1Password item name (default: \$AWS_OP_ITEM)"
complete -c awsop -l vault -r -d "1Password vault name (default: \$AWS_OP_VAULT)"
complete -c awsop -s h -l help -d "Show help message"

# AWS subcommands (after flags are provided)
set -l aws_subcommands s3 s3api ec2 iam rds lambda sts ecs eks sqs sns dynamodb cloudformation cloudwatch logs ssm secretsmanager route53 elb elbv2 autoscaling kms sso configure

for sub in $aws_subcommands
    complete -c awsop -n "not __fish_seen_subcommand_from doctor" -a "$sub" -d "aws $sub"
end
