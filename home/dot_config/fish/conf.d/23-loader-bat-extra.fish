if status is-interactive
    cached-init batman; or begin
        command -q batman; and batman --export-env | source
    end

    cached-init batpipe; or begin
        command -q batpipe; and batpipe | source
    end
end
