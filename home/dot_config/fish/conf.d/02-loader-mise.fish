# 02-loader-direnv.fish
if command -q mise
    mise activate fish | source
    # Execute hook immediately to set up environment for current directory
    mise hook-env -s fish | source
end
