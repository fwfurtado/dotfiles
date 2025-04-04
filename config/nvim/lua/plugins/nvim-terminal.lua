return {
    's1n7ax/nvim-terminal',
    keys = function()
        local term = require('nvim-terminal').DefaultTerminal;

        local mapping_opts = { silent = true } 

        return {
            {
                '<leader>t',
                function ()
                    term:toggle()
                end,
                desc = 'Toggle Terminal',
                mmapping_opt
            },
        }
    end
}
