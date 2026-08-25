function cached-init --argument name --description 'sourceia init pré-gerado em ~/.cache/fish/init'
    set -l cache (set -q XDG_CACHE_HOME; and echo $XDG_CACHE_HOME; or echo $HOME/.cache)/fish/init/$name.fish

    if test -f $cache
        source $cache
        return 0
    end

    return 1
end
