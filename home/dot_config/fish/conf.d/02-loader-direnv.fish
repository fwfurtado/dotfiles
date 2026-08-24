# 02-loader-direnv.fish
if command -q direnv
    direnv hook fish | source
end
