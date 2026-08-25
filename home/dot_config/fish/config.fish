set fish_greeting

# PATH e env vivem em conf.d/ (00-env, 01-path). Nada de caminho absoluto aqui:
# quebra no macOS, onde $HOME é /Users/<user>.

if test "$TERM_PROGRAM" = ghostty
    set -gx TERM xterm-256color
end
