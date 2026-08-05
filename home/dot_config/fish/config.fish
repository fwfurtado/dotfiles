set fish_greeting

# status is-interactive; and begin
#     set fish_tmux_autostart true
# end

if test "$TERM_PROGRAM" = "ghostty"
    export TERM=xterm-256color
end

# opencode
fish_add_path /home/fwfurtado/.opencode/bin


# Added by LM Studio CLI (lms)
set -gx PATH $PATH /home/fwfurtado/.lmstudio/bin
# End of LM Studio CLI section



# Added by ToolHive UI - do not modify this block
fish_add_path -g $HOME/.toolhive/bin
# End ToolHive UI
