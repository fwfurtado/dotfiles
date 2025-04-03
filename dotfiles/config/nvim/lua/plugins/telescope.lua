return { 
	'nvim-telescope/telescope.nvim', 
	tag = '0.1.8', 
	dependencies = { 'nvim-lua/plenary.nvim' }, 

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
