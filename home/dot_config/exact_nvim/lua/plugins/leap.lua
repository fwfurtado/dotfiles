return {
    'ggandor/leap.nvim',
    dependencies = { 'tpope/vim-repeat' },
    keys = {
        {
            '<leader>s',
            function ()
                require('leap').leap {}
            end,
            mode = { 'n', 'x', 'o' }
        },
    },
}
