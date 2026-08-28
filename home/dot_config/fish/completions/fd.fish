complete -c fdfind -l and -d 'Additional search patterns that need to be matched' -r
complete -c fdfind -s d -l max-depth -d 'Set maximum search depth (default: none)' -r
complete -c fdfind -l min-depth -d 'Only show search results starting at the given depth.' -r
complete -c fdfind -l exact-depth -d 'Only show search results at the exact given depth' -r
complete -c fdfind -s E -l exclude -d 'Exclude entries that match the given glob pattern' -r
complete -c fdfind -s t -l type -d 'Filter by type: file (f), directory (d/dir), symlink (l), executable (x), empty (e), socket (s), pipe (p), char-device (c), block-device (b)' -r -f -a "file\t''
directory\t''
symlink\t''
block-device\t''
char-device\t''
executable\t'A file which is executable by the current effective user'
empty\t''
socket\t''
pipe\t''"
complete -c fdfind -s e -l extension -d 'Filter by file extension' -r
complete -c fdfind -s S -l size -d 'Limit results based on the size of files' -r
complete -c fdfind -l changed-within -d 'Filter by file modification time (newer than)' -r
complete -c fdfind -l changed-before -d 'Filter by file modification time (older than)' -r
complete -c fdfind -s o -l owner -d 'Filter by owning user and/or group' -r
complete -c fdfind -l format -d 'Print results according to template' -r
complete -c fdfind -s x -l exec -d 'Execute a command for each search result' -r
complete -c fdfind -s X -l exec-batch -d 'Execute a command with all search results at once' -r
complete -c fdfind -l batch-size -d 'Max number of arguments to run as a batch size with -X' -r
complete -c fdfind -l ignore-file -d 'Add a custom ignore-file in \'.gitignore\' format' -r -F
complete -c fdfind -s c -l color -d 'When to use colors' -r -f -a "auto\t'show colors if the output goes to an interactive console (default)'
always\t'always use colorized output'
never\t'do not use colorized output'"
complete -c fdfind -l hyperlink -d 'Add hyperlinks to output paths' -r -f -a "auto\t'Use hyperlinks only if color is enabled'
always\t'Always use hyperlinks when printing file paths'
never\t'Never use hyperlinks'"
complete -c fdfind -s j -l threads -d 'Set number of threads to use for searching & executing (default: number of available CPU cores)' -r
complete -c fdfind -l max-buffer-time -d 'Milliseconds to buffer before streaming search results to console' -r
complete -c fdfind -l max-results -d 'Limit the number of search results' -r
complete -c fdfind -l base-directory -d 'Change current working directory' -r -F
complete -c fdfind -l path-separator -d 'Set path separator when printing file paths' -r
complete -c fdfind -l search-path -d 'Provides paths to search as an alternative to the positional <path> argument' -r -F
complete -c fdfind -l strip-cwd-prefix -d 'By default, relative paths are prefixed with \'./\' when -x/--exec, -X/--exec-batch, or -0/--print0 are given, to reduce the risk of a path starting with \'-\' being treated as a command line option. Use this flag to change this behavior. If this flag is used without a value, it is equivalent to passing "always"' -r -f -a "auto\t'Use the default behavior'
always\t'Always strip the ./ at the beginning of paths'
never\t'Never strip the ./'"
complete -c fdfind -l gen-completions -r -f -a "bash\t''
elvish\t''
fish\t''
powershell\t''
zsh\t''"
complete -c fdfind -s H -l hidden -d 'Search hidden files and directories'
complete -c fdfind -l no-hidden -d 'Overrides --hidden'
complete -c fdfind -s I -l no-ignore -d 'Do not respect .(git|fd)ignore files'
complete -c fdfind -l ignore -d 'Overrides --no-ignore'
complete -c fdfind -l no-ignore-vcs -d 'Do not respect .gitignore files'
complete -c fdfind -l ignore-vcs -d 'Overrides --no-ignore-vcs'
complete -c fdfind -l no-require-git -d 'Do not require a git repository to respect gitignores. By default, fd will only respect global gitignore rules, .gitignore rules, and local exclude rules if fd detects that you are searching inside a git repository. This flag allows you to relax this restriction such that fd will respect all git related ignore rules regardless of whether you\'re searching in a git repository or not'
complete -c fdfind -l require-git -d 'Overrides --no-require-git'
complete -c fdfind -l no-ignore-parent -d 'Do not respect .(git|fd)ignore files in parent directories'
complete -c fdfind -l no-global-ignore-file -d 'Do not respect the global ignore file'
complete -c fdfind -s u -l unrestricted -d 'Unrestricted search, alias for \'--no-ignore --hidden\''
complete -c fdfind -s s -l case-sensitive -d 'Case-sensitive search (default: smart case)'
complete -c fdfind -s i -l ignore-case -d 'Case-insensitive search (default: smart case)'
complete -c fdfind -s g -l glob -d 'Glob-based search (default: regular expression)'
complete -c fdfind -l regex -d 'Regular-expression based search (default)'
complete -c fdfind -s F -l fixed-strings -d 'Treat pattern as literal string stead of regex'
complete -c fdfind -s a -l absolute-path -d 'Show absolute instead of relative paths'
complete -c fdfind -l relative-path -d 'Overrides --absolute-path'
complete -c fdfind -s l -l list-details -d 'Use a long listing format with file metadata'
complete -c fdfind -s L -l follow -d 'Follow symbolic links'
complete -c fdfind -l no-follow -d 'Overrides --follow'
complete -c fdfind -s p -l full-path -d 'Search full abs. path (default: filename only)'
complete -c fdfind -s 0 -l print0 -d 'Separate search results by the null character'
complete -c fdfind -l prune -d 'Do not traverse into directories that match the search criteria. If you want to exclude specific directories, use the \'--exclude=…\' option'
complete -c fdfind -s 1 -d 'Limit search to a single result'
complete -c fdfind -s q -l quiet -d 'Print nothing, exit code 0 if match found, 1 otherwise'
complete -c fdfind -l show-errors -d 'Show filesystem errors'
complete -c fdfind -l one-file-system -d 'By default, fd will traverse the file system tree as far as other options dictate. With this flag, fd ensures that it does not descend into a different file system than the one it started in. Comparable to the -mount or -xdev filters of find(1)'
complete -c fdfind -s h -l help -d 'Print help (see more with \'--help\')'
complete -c fdfind -s V -l version -d 'Print version'
