function y --description 'yazi com cd ao sair; aceita keywords do zoxide'
    set -l argc (count $argv)
    set -l target

    if test $argc -eq 0
        # sem argumento: diretório atual
    else if test "$argv" = -
        set target $dirprev[-1]
    else if test $argc -eq 1; and test -e "$argv[1]"
        # exatamente um argumento e ele existe: caminho literal
        set target $argv[1]
    else if test $argc -eq 2; and test "$argv[1]" = --
        set target $argv[2]
    else if string match -q -- '-*' "$argv[1]"
        # flags do yazi (-h, --version...): repassa
        set target $argv
    else
        # qualquer outra coisa: keywords do zoxide
        set target (command zoxide query --exclude "$PWD" -- $argv); or return
    end

	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $target --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		cd "$cwd"
	end
	command rm -f -- "$tmp"
end
