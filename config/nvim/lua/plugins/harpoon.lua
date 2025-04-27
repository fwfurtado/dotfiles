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
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon add file",
			},
            {
				"<leader>hr",
				function()
					require("harpoon"):list():remove()
				end,
				desc = "Harpoon remove file",
			},
			{
				"<leader>h",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon Quick Menu",
			},
			{
				"<leader>hn",
				function()
					require("harpoon"):list():next({ ui_nav_wrap = true })
				end,
				desc = "Harpoon next file"
			},
			{
				"<leader>hp",
				function()
					require("harpoon"):list():prev({ ui_nav_wrap = true })
				end,
				desc = "Harpoon previous file"
			},
		}

		return keys
	end,
}
