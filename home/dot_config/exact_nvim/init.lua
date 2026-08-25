-- ~/.config/nvim/init.lua — Neovim 0.12+, zero plugins externos
vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
local o = vim.o

o.number = true
o.relativenumber = true
o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.winborder = 'rounded'

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true

o.ignorecase = true
o.smartcase = true
o.inccommand = 'split'

o.undofile = true
o.swapfile = false
o.updatetime = 250

o.splitbelow = true
o.splitright = true

-- :find <Tab> vira um finder decente sem plugin
o.path = '.,**'
o.wildignore = '**/.git/*,**/node_modules/*,**/target/*,**/build/*,**/.venv/*'
o.wildoptions = 'pum,fuzzy'

-- completação embutida
o.completeopt = 'menuone,noselect,fuzzy,popup'

-- :grep usando ripgrep, resultado no quickfix
if vim.fn.executable('rg') == 1 then
    o.grepprg = 'rg --vimgrep --smart-case'
    o.grepformat = '%f:%l:%c:%m'
end

vim.cmd.colorscheme('default')

--------------------------------------------------------------------------------
-- Treesitter (parsers do core: c, lua, markdown, query, vim, vimdoc)
--------------------------------------------------------------------------------
-- Nas demais linguagens o realce cai nos arquivos de syntax do Vim, que existem
-- para rust, go, python, kotlin, dart e zig. Funciona; é menos preciso.
vim.api.nvim_create_autocmd('FileType', {
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
})

--------------------------------------------------------------------------------
-- LSP — definido à mão, sem nvim-lspconfig
--------------------------------------------------------------------------------
local servers = {
    rust_analyzer = {
        cmd = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'rust-project.json' },
    },
    gopls = {
        cmd = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.work', 'go.mod', '.git' },
    },
    zls = {
        cmd = { 'zls' },
        filetypes = { 'zig', 'zir' },
        root_markers = { 'build.zig', '.git' },
    },
    lua_ls = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
        settings = {
            Lua = {
                runtime = { version = 'LuaJIT' },
                workspace = { library = vim.api.nvim_get_runtime_file('', true) },
                diagnostics = { globals = { 'vim' } },
            },
        },
    },
    basedpyright = {
        cmd = { 'basedpyright-langserver', '--stdio' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
    },
    ruff = {
        cmd = { 'ruff', 'server' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'ruff.toml', '.git' },
    }
}

for name, config in pairs(servers) do
    vim.lsp.config(name, config)
    -- só habilita o que existe no PATH: evita ruído em máquina sem a toolchain
    if vim.fn.executable(config.cmd[1]) == 1 then
        vim.lsp.enable(name)
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
        end
    end,
})

vim.diagnostic.config({
    virtual_text = { current_line = true },
    severity_sort = true,
    signs = true,
})

--------------------------------------------------------------------------------
-- Keymaps
--------------------------------------------------------------------------------
-- Defaults de LSP do 0.11+ já cobrem: K (hover), grn (rename), gra (code action),
-- grr (references), gri (implementation), gO (symbols), CTRL-S (signature).
local map = vim.keymap.set

map('n', '<leader>ff', ':find ', { desc = 'Find file' })
map('n', '<leader>fb', ':buffer ', { desc = 'Buffer' })
map('n', '<leader>fg', ':silent grep ', { desc = 'Grep' })
map('n', '<leader>fq', '<cmd>copen<cr>', { desc = 'Quickfix' })
map('n', '<leader>fd', vim.diagnostic.setqflist, { desc = 'Diagnostics no quickfix' })

map('n', '<leader>e', '<cmd>Explore<cr>', { desc = 'File explorer' })
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Write' })
map('n', '<esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear highlight' })

map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, { desc = 'Format' })
map('n', '<leader>ld', vim.diagnostic.open_float, { desc = 'Line diagnostics' })

map('v', 'J', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
map('v', 'K', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })
map('x', '<leader>p', [["_dP]], { desc = 'Paste keeping register' })

--------------------------------------------------------------------------------
-- Autocmds
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.hl.on_yank() end,
})

-- grep abre o quickfix automaticamente
vim.api.nvim_create_autocmd('QuickFixCmdPost', {
    pattern = { 'grep', 'grepadd' },
    command = 'cwindow',
})
