function cached-init --argument name --description 'sourceia init pré-gerado'
    set -l cache (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)/fish/init/$name.fish
    set -l bin (command -v $name)

    # cache mais novo que o binário, senão regenera
    if test -f $cache; and test -n "$bin"; and test $cache -nt $bin
        source $cache
        return 0
    end

    return 1
end
