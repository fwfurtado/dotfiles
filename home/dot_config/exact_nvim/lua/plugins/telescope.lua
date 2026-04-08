return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	dependencies = {
        'nvim-lua/plenary.nvim',
        'BurntSushi/ripgrep',
        'sharkdp/fd',
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
    },

    config = function ()
        require('telescope').setup {
            defaults = {
                preview = {
                    mime_hook = function(filepath, bufnr, opts)
                        local is_image = function(filepath)
                            local image_extensions = {'png', 'jpeg', 'jpg'}   -- Supported image formats
                            local split_path = vim.split(filepath:lower(), '.', {plain=true})
                            local extension = split_path[#split_path]
                            return vim.tbl_contains(image_extensions, extension)
                        end
                        if is_image(filepath) then
                            local term = vim.api.nvim_open_term(bufnr, {})
                            local function send_output(_, data, _ )
                                for _, d in ipairs(data) do
                                    vim.api.nvim_chan_send(term, d..'\r\n')
                                end
                            end
                            vim.fn.jobstart(
                                {
                                    'catimg', filepath  -- Terminal image viewer command
                                }, 
                                {on_stdout=send_output, stdout_buffered=true, pty=true})
                            else
                                require("telescope.previewers.utils").set_preview_message(bufnr, opts.winid, "Binary cannot be previewed")
                            end
                        end
                    },
                },
                pickers = {
                    find_files = {
                        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,                    -- false will only do exact matching
                        override_generic_sorter = true,  -- override the generic sorter
                        override_file_sorter = true,     -- override the file sorter
                        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    }
                }
            }
            require('telescope').load_extension('fzf')
    end,

	keys = {
		{
			"<leader>pf",
			function()
				require("telescope.builtin").find_files()
			end,
			desc = "Telecope find files",
			mode = "n",
		},
		{
			"<leader>ps",
			function()
				require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") });
			end,
			desc = "Telescope grep",
			mode = "n",
		},
		{
			"<C-p>",
			function()
				require("telescope.builtin").git_files()
			end,
			desc = "Telescope find git files",
			mode = "n",

		}
	}
}
