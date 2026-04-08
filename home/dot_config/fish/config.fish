set fish_greeting

# status is-interactive; and begin
#     set fish_tmux_autostart true
# end

if test "$TERM_PROGRAM" = "ghostty"
    export TERM=xterm-256color
end
