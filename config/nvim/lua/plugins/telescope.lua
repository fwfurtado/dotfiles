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
