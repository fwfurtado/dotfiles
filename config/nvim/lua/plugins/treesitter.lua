return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
        "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
        local config = require("nvim-treesitter.configs")

        config.setup({
            ensure_installed = {
                "c",
                "lua",
                "vim",
                "vimdoc",
                "query",
                "elixir",
                "rust",
                "go",
                "javascript",
                "typescript",
                "python",
                "zig",
                "yaml",
                "toml",
                "html",
                "sql",
            },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            sync_install = false,
            auto_install = true,
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["as"] = "@statement.outer",
                        ["is"] = "@statement.inner",
                        ["ap"] = "@parameter.outer",
                        ["ip"] = "@parameter.inner",
                        ["ab"] = "@block.outer",
                        ["ib"] = "@block.inner",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<leader>sn"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<leader>sp"] = "@parameter.inner",
                    },
                },
                lsp_interop = {
                    enable = true,
                    border = "rounded",
                    peek_definition_code = {
                        ["<leader>df"] = "@function.outer",
                        ["<leader>dF"] = "@class.outer",
                        ["<leader>ds"] = "@statement.outer",
                    },
                },
            },
        })
    end,
}
