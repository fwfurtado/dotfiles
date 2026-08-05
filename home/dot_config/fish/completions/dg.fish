function _dg_completion
    set -l words (commandline -op)
    set -l cword (commandline -t)
    
    set -l cache_key (string join '_' $words | string replace -ar '[^a-zA-Z0-9_-]' '')
    set -l cache_file /tmp/.dg_completion_$cache_key
    set -l cache_ttl 3600

    if test -f $cache_file
        set -l cache_age (math (date +%s) - (stat -c %Y $cache_file 2>/dev/null; or echo 0))
        if test $cache_age -gt $cache_ttl
            env _DG_COMPLETE=fish_complete COMP_WORDS=(commandline -cp) COMP_CWORD=$cword dg > $cache_file &
        end
        _dg_parse_cache $cache_file
        return
    end

    set -l raw (env _DG_COMPLETE=fish_complete COMP_WORDS=(commandline -cp) COMP_CWORD=$cword dg | tee $cache_file)
    _dg_parse_response $raw
end

function _dg_parse_cache
    set -l lines (cat $argv[1])
    _dg_parse_response $lines
end

function _dg_parse_response
    set -l response $argv
    set -l i 1
    while test $i -le (count $response)
        set -l type  $response[$i]
        set -l value $response[(math $i + 1)]
        set -l desc  $response[(math $i + 2)]

        if test "$type" = "dir"
            __fish_complete_directories $value
        else if test "$type" = "file"
            __fish_complete_path $value
        else if test "$type" = "plain"
            if test "$desc" != "_"
                printf "%s\t%s\n" $value $desc
            else
                echo $value
            end
        end

        set i (math $i + 3)
    end
end

complete --no-files --command dg --arguments "(_dg_completion)"
