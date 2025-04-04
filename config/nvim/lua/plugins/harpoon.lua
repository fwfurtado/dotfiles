return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	opts = {
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4,
		},
		settings = {
			save_on_toggle = true,
		},
	},
	keys = function()
		local keys = {
			{
				"<leader>a",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon File",
			},
			{
				"<C-r>",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon Quick Menu",
			},
			{
				"<C-n>",
				function()
					require("harpoon"):list():select(1)
				end,
				desc = "Harpoon to file 1"
			},
			{
				"<C-e>",
				function()
					require("harpoon"):list():select(2)
				end,
				desc = "Harpoon to file 2"
			},
			{
				"<C-i>",
				function()
					require("harpoon"):list():select(3)
				end,
				desc = "Harpoon to file 3"
			},
			{
				"<C-o>",
				function()
					require("harpoon"):list():select(4)
				end,
				desc = "Harpoon to file 4"
			},
		}

		return keys
	end,
}
