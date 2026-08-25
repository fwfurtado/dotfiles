if status is-interactive
    cached-init batman; or begin
        command -q batman; batman --export-env | source
    end

    cached-init batpipe; or begin
        command -q batpipe; eval (batpipe)
    end
end
