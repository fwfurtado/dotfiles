return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	opts_extend = { "ensure_installed" },
	opts = {
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
		sync_install = false,
		auto_install = true,
		ensure_installed = { 
			"c",
			"lua",
			"rust",
			"go",
			"javascript",
			"typescript",
			"python",
		}
	}

}
