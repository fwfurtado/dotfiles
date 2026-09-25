if set -q YAZI_ID
    function __yazi_sync_cwd --on-event fish_exit
        ya emit cd "$PWD"
    end
end
