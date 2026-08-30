-- ~/.config/nvim/init.lua — Neovim 0.12+, um único plugin (nvim-treesitter)
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


-- usar clipboard do SO.
vim.schedule(function()
    vim.o.clipboard = 'unnamedplus'
end)

-- forçar OSC 52 quando o provider nativo não serve
if vim.env.SSH_TTY then
    local osc52 = require('vim.ui.clipboard.osc52')
    vim.g.clipboard = {
        name = 'OSC 52',
        copy = { ['+'] = osc52.copy('+'), ['*'] = osc52.copy('*') },
        paste = { ['+'] = osc52.paste('+'), ['*'] = osc52.paste('*') },
    }
end

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------
-- Hook precisa ser registrado ANTES do vim.pack.add, senão não roda na primeira
-- instalação nem no bootstrap a partir do lockfile.
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind ~= 'delete' then
            if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
            vim.cmd('TSUpdate')
        end
    end,
})

vim.pack.add({
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/stevearc/oil.nvim',
})


vim.cmd.colorscheme('minicyan')

--------------------------------------------------------------------------------
-- Treesitter
--------------------------------------------------------------------------------
local parsers = {
    'bash', 'c', 'dart', 'diff', 'dockerfile', 'fish', 'go', 'gomod', 'gosum',
    'gitcommit', 'hcl', 'json', 'kotlin', 'lua', 'make', 'markdown',
    'markdown_inline', 'python', 'query', 'rust', 'sql', 'toml', 'vim',
    'vimdoc', 'yaml', 'zig',
}

require('nvim-treesitter').install(parsers)

--------------------------------------------------------------------------------
-- mini.nvim
--------------------------------------------------------------------------------
require('mini.icons').setup()
require('mini.icons').mock_nvim_web_devicons()

require('mini.surround').setup({
    search_method = 'nearest'
})

-- gen_ai_spec vive no módulo, não depende de MiniExtra.setup() ter rodado.
local gen_ai_spec = require('mini.extra').gen_ai_spec

local ai = require('mini.ai')
ai.setup({
    n_lines = 500,
    custom_textobjects = {
        -- Estes dependem de queries `textobjects.scm`, que NÃO vêm no
        -- nvim-treesitter (branch main só traz highlights/indents/folds/locals).
        -- Quem fornece é o nvim-treesitter-textobjects, no vim.pack.add acima.
        -- Sem ele: "Can not get query for buffer N and language X".

        -- argumento/parâmetro (44 linguagens; substitui o `a` por patterns)
        a = ai.gen_spec.treesitter({ a = '@parameter.outer', i = '@parameter.inner' }),

        -- chamada de função — recupera o que o `f` built-in fazia
        F = ai.gen_spec.treesitter({ a = '@call.outer', i = '@call.inner' }),

        f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
        c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
        o = ai.gen_spec.treesitter({
            a = { '@conditional.outer', '@loop.outer' },
            i = { '@conditional.inner', '@loop.inner' },
        }),

        -- bloco e comentário
        k = ai.gen_spec.treesitter({ a = '@block.outer', i = '@block.inner' }),
        C = ai.gen_spec.treesitter({ a = '@comment.outer', i = '@comment.outer' }),

        -- os abaixo não dependem de parser treesitter: funcionam em qualquer buffer
        B = gen_ai_spec.buffer(),
        D = gen_ai_spec.diagnostic(),
        I = gen_ai_spec.indent(),
        L = gen_ai_spec.line(),
        N = gen_ai_spec.number(),
    },
})

require('mini.pick').setup()

-- Precisa vir DEPOIS de mini.pick: MiniExtra.setup() só registra os pickers em
-- MiniPick.registry se o global MiniPick já existir (extra.lua, apply_config).
require('mini.extra').setup()
require('mini.files').setup({
    mappings = {
        go_in = '<Right>',
        go_out = '<Left>',
    }
})

require('mini.move').setup({
    mappings = {
        left = '<M-Left>',
        right = '<M-Right>',
        down = '<M-Down>',
        up = '<M-Up>',

        line_left = '<M-Left>',
        line_right = '<M-Right>',
        line_down = '<M-Down>',
        line_up = '<M-Up>',
    }
})

require('mini.animate').setup()
require('mini.indentscope').setup()
require('mini.trailspace').setup()
require('mini.statusline').setup()
require('mini.statuscolumn').setup()
require('mini.tabline').setup()

-- mini.clue — janela de dicas para prefixos de teclas.
-- As descrições vêm do campo `desc` dos mapeamentos já existentes; os `clues`
-- abaixo só nomeiam os GRUPOS (o que aparece antes da segunda tecla).
local miniclue = require('mini.clue')
miniclue.setup({
    triggers = {
        { mode = { 'n', 'x' }, keys = '<Leader>' },
        { mode = 'n', keys = '<C-w>' },
        { mode = { 'n', 'x' }, keys = 'g' },
        { mode = { 'n', 'x' }, keys = 'z' },
        { mode = { 'n', 'x' }, keys = "'" },
        { mode = { 'n', 'x' }, keys = '`' },
        { mode = { 'n', 'x' }, keys = '"' },
        { mode = { 'n', 'x' }, keys = '[' },
        { mode = { 'n', 'x' }, keys = ']' },
        { mode = { 'i', 'c' }, keys = '<C-r>' },
        { mode = 'i', keys = '<C-x>' },
    },

    clues = {
        { mode = 'n', keys = '<Leader>f', desc = '+Find' },
        { mode = 'n', keys = '<Leader>g', desc = '+Git' },
        { mode = 'n', keys = '<Leader>l', desc = '+LSP' },

        -- conjuntos prontos para teclas built-in do Vim
        miniclue.gen_clues.g(),
        miniclue.gen_clues.z(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.square_brackets(),
    },

    window = { delay = 300 },
})

--------------------------------------------------------------------------------
-- oil.nvim — em avaliação, convivendo com mini.files
--------------------------------------------------------------------------------
-- default_file_explorer = false enquanto isso for teste: assumir os buffers de
-- diretório é irreversível dentro da sessão e mudaria o comportamento de
-- `nvim .` sem você pedir. Vire para true se decidir adotar.
require('oil').setup({
    default_file_explorer = false,

    -- mini.icons já está carregado e faz mock de nvim-web-devicons,
    -- então a coluna de ícone funciona sem dependência nova.
    columns = { 'icon' },

    delete_to_trash = true,
    watch_for_changes = true,

    lsp_file_methods = {
        enabled = true,
        timeout_ms = 1000,   -- mesmo default do options.lsp_timeout do mini.files
    },

    view_options = {
        show_hidden = true,
    },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = parsers,
    callback = function()
        -- realce, dobra e indentação baseados na árvore sintática
        pcall(vim.treesitter.start)
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

-- dobras existem mas começam todas abertas
o.foldmethod = 'expr'
o.foldlevelstart = 99

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
    },
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

        -- Triggers do mini.clue são mapeamentos buffer-local e precisam ser os
        -- mais recentes. O LSP cria os seus no attach, então recria os triggers
        -- depois (doc do mini.clue, "Triggers are implemented as special
        -- buffer-local mappings").
        vim.schedule(function()
            if vim.api.nvim_buf_is_valid(ev.buf) then
                MiniClue.ensure_buf_triggers(ev.buf)
            end
        end)
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

map('n', '<leader>ff', '<cmd>Pick files<cr>', { desc = 'Find files' })
map('n', '<leader>fb', '<cmd>Pick buffers<cr>', { desc = 'Buffers' })
map('n', '<leader>fg', '<cmd>Pick grep_live<cr>', { desc = 'Live grep' })
map('n', '<leader>fh', '<cmd>Pick help<cr>', { desc = 'Help' })
map('n', '<leader>fd', '<cmd>Pick diagnostic<cr>', { desc = 'Diagnostics' })
map('n', '<leader>fr', '<cmd>Pick resume<cr>', { desc = 'Retoma última busca' })

-- pickers do mini.extra
map('n', '<leader>fo', '<cmd>Pick oldfiles<cr>', { desc = 'Oldfiles' })
map('n', '<leader>fl', '<cmd>Pick buf_lines scope="current"<cr>', { desc = 'Linhas do buffer' })
map('n', '<leader>fk', '<cmd>Pick keymaps<cr>', { desc = 'Keymaps' })
map('n', '<leader>fC', '<cmd>Pick colorschemes<cr>', { desc = 'Colorschemes' })
map('n', '<leader>fH', '<cmd>Pick hl_groups<cr>', { desc = 'Highlight groups' })
map('n', '<leader>f:', '<cmd>Pick history scope=":"<cr>', { desc = 'Histórico de comandos' })

map('n', '<leader>fq', '<cmd>Pick list scope="quickfix"<cr>', { desc = 'Quickfix' })
map('n', '<leader>fj', '<cmd>Pick list scope="jump"<cr>', { desc = 'Jump list' })
map('n', '<leader>fc', '<cmd>Pick list scope="change"<cr>', { desc = 'Change list' })

map('n', '<leader>gf', '<cmd>Pick git_files<cr>', { desc = 'Git files' })
map('n', '<leader>gh', '<cmd>Pick git_hunks<cr>', { desc = 'Git hunks' })
map('n', '<leader>gH', '<cmd>Pick git_hunks scope="staged"<cr>', { desc = 'Git hunks (staged)' })
map('n', '<leader>gc', '<cmd>Pick git_commits<cr>', { desc = 'Git commits' })
map('n', '<leader>gb', '<cmd>Pick git_branches<cr>', { desc = 'Git branches' })

map('n', '<leader>lr', '<cmd>Pick lsp scope="references"<cr>', { desc = 'LSP references' })
map('n', '<leader>ls', '<cmd>Pick lsp scope="document_symbol"<cr>', { desc = 'LSP symbols' })
map('n', '<leader>lS', '<cmd>Pick lsp scope="workspace_symbol_live"<cr>', { desc = 'LSP workspace symbols' })
map('n', '<leader>lg', '<cmd>Pick lsp scope="definition"<cr>', { desc = 'LSP definition' })
map('n', '<leader>li', '<cmd>Pick lsp scope="implementation"<cr>', { desc = 'LSP implementation' })

map('n', '<leader>e', '<cmd>Pick explorer<cr>', { desc = 'Navegar' })
map('n', '<leader>E', function()
    require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
end, { desc = 'File explorer' })
map('n', '<leader>o', '<cmd>Oil<cr>', { desc = 'Oil (diretório do buffer)' })

map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Write' })
map('n', '<esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear highlight' })

map('n', '<leader>lf', function() vim.lsp.buf.format({ async = true }) end, { desc = 'Format' })
map('n', '<leader>ld', vim.diagnostic.open_float, { desc = 'Line diagnostics' })

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
