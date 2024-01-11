export-env {
    load-env {
        SYSTEMD_EDITOR: 'nvim'
        SUDO_EDITOR: 'nvim'
        EDITOR: 'nvim'
        VISUAL: 'nvim'
        LS_COLORS: (vivid generate one-dark | str trim)

        FZF_DEFAULT_OPTS: '--height 40% --no-bold --layout reverse --border'
        GPG_TTY: (tty)
        OTHER_MIMI_ENV: "mimi"
    }
}
