-- reduce startup time
vim.loader.enable()

-- set leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = vim.g.mapleader

-- install plugin manager
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- define and configure plugins
require('lazy').setup({
    'tpope/vim-fugitive',         -- git wrapper
    'mbbill/undotree',            -- undo view
    'tpope/vim-sleuth',           -- detect tabs automatically
    'mg979/vim-visual-multi',     -- multicursor editing
    'lervag/vimtex',              -- latex all-around helper
    {
        -- quickstart configs for lsp
        'neovim/nvim-lspconfig',
        dependencies = {
            -- servers package manager
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},
        },
        config = function()
            -- function executed when server get attached to buffer
	    local on_attach = function(client, bufnr)
                -- disable annoying lsp syntax highlighting
                client.server_capabilities.semanticTokensProvider = nil

                local fzf = require('fzf-lua')
                local opts = {buffer = bufnr, remap = false}

                -- show symbols info
                vim.keymap.set('n', '<c-k>', vim.lsp.buf.signature_help, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)

                vim.keymap.set('n', '<leader>gr', fzf.lsp_references, opts)
                vim.keymap.set('n', '<leader>gd', fzf.lsp_definitions, opts)
                vim.keymap.set('n', '<leader>gi', fzf.lsp_implementations, opts)
                vim.keymap.set('n', '<leader>gs', fzf.lsp_document_symbols, opts)
                vim.keymap.set('n', '<leader>ws', fzf.lsp_live_workspace_symbols, opts)
            end

            require('mason').setup({})
            require("mason-lspconfig").setup({})

            local servers = {
                clangd = {},
                lua_ls = {
                    Lua = {
                        diagnostics = {globals = {'vim'}},
                        telemetry = {enable = false},
                        runtime = {
                            version = "LuaJIT",
                            path = vim.split(package.path, ";"),
                        },
                        workspace = {
                            library = { vim.env.VIMRUNTIME },
                            checkThirdParty = false,
                        },
                    }
                },
            }

            local mason_lspconfig = require('mason-lspconfig')
            mason_lspconfig.setup({
                ensure_installed = vim.tbl_keys(servers),
            })

            -- additional completion capabilitites
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            local lsp_config = require('lspconfig')
            mason_lspconfig.setup_handlers({
                function(server_name)
                    lsp_config[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                        filetypes = (servers[server_name] or {}).filetypes,
                    })
                end,
            })
        end
    },
    {
        -- completion engine
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- snippet engine
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- lsp completion capabilities
            'hrsh7th/cmp-nvim-lsp',

            -- path capabilities
            'hrsh7th/cmp-path',

            -- set of useful snippets
            'rafamadriz/friendly-snippets',
        },
        config = function()
            local cmp = require('cmp')
            local cmp_select = {behavior = cmp.SelectBehavior.Select}

            -- load set of snippets
            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                sources = cmp.config.sources({
                        {name = 'nvim_lsp'},
                        {name = 'luasnip'},
                        {name = 'path'},
                    }, {{name = 'buffer'}}
                ),
                mapping = cmp.mapping.preset.insert({
                    ['<c-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<c-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<c-y>'] = cmp.mapping.confirm({select = true}),
                    ['<c-d>'] = cmp.mapping.scroll_docs(4),
                    ['<c-u>'] = cmp.mapping.scroll_docs(-4),
                })
            })
        end
    },
    {
        -- comment lines/regions
        'numToStr/Comment.nvim',
        opts = {}
    },
    {
        -- further text objects
        'echasnovski/mini.ai',
        version = '*',
        opts = {}
    },
    {
        -- highlight, edit and navigate code
        'nvim-treesitter/nvim-treesitter',
        main = 'nvim-treesitter.configs',
        build = ':TSUpdate',
        opts = {
            auto_install = true,
            indent = {enable = true},
            highlight = {enable = false},
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = '<c-space>',
                    node_incremental = '<c-space>',
                    node_decremental = '<M-space>',
                    scope_incremental = '<c-s>',
                },
            }
        }
    },
    {
        -- file system navigation
        'stevearc/oil.nvim',
        opts = {
            delete_to_trash = true,
            columns = {'size', 'permissions'},
            prompt_save_on_select_new_entry = false,
            skip_confirm_for_simple_edits = true,
        }
    },
    {
        -- fzf integration
        'ibhagwan/fzf-lua',
        build = './install --bin',
        opts = {
            'fzf-vim',
            winopts = {split = 'belowright new'},
        }
    },
    {
        'rebelot/kanagawa.nvim',
        priority = 55,
        config = function()
            require('kanagawa').setup({undercurl = false})
            vim.cmd.colorscheme('kanagawa-dragon')
            vim.api.nvim_set_hl(0, 'CursorLine', {link = 'ColorColumn'})
        end,
    }
}, {})

-- use zathura for pdf viewing
vim.g.vimtex_view_method = 'zathura'

-- hide '~' at buffer end
vim.opt.fillchars:append({eob = ' '})

-- show numbers
vim.opt.number         = true
vim.opt.relativenumber = true

-- set case insensitiveness, alter with \C
vim.opt.ignorecase     = true
vim.opt.smartcase      = true

-- make undo history everlasting
vim.opt.undofile       = true

-- appropriate indent on new line
vim.opt.smartindent    = true

-- proper tabs config
vim.opt.tabstop        = 4
vim.opt.softtabstop    = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true

-- block swap file creation
vim.opt.swapfile       = false

-- define languages for spelling feature
vim.opt.spelllang      = {'en_us', 'it'}

-- ui tweaks
vim.opt.termguicolors  = true
vim.opt.cursorline     = true
vim.opt.guicursor      = 'i:block'
vim.opt.signcolumn     = 'yes'
vim.opt.colorcolumn    = '80'
vim.opt.pumheight      = 5
vim.opt.cmdwinheight   = 5

-- diagnostics keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- exit insert mode
vim.keymap.set('i', '<c-c>', '<esc>')

-- no highlight for matching words
vim.keymap.set('n', '<leader>h', ':noh<cr>', {silent = true})

-- move selected text horizontally
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<', '<gv')

-- paste on selected text without yanking
vim.keymap.set('v', 'p', '"_dhp')

-- yank into system register
vim.keymap.set('v', '<leader>y', '"+y')

-- delete without yanking
vim.keymap.set('v', '<leader>d', '"_d')

-- deal with line wrap
vim.keymap.set('n', 'j', 'v:count == 0 ? "gj" : "j"', {expr = true})
vim.keymap.set('n', 'k', 'v:count == 0 ? "gk" : "k"', {expr = true})

-- open parent directory
vim.keymap.set('n', '-', require('oil').open)

local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>k', fzf.builtin)

-- find directories recursively
vim.keymap.set('n', '<leader>d', function() fzf.files({cmd = 'find . -not -path "*/.*" -type d'}) end)

-- find all files except executable ones
vim.keymap.set('n', '<leader>f', function() fzf.files({cmd = 'find . ! -perm -111 -not -path "*/.*"'}) end)

-- live grep working directory
vim.keymap.set('n', '<leader>s', fzf.live_grep_native)

-- grep visual selection
vim.keymap.set('v', '<leader>s', fzf.grep_visual)

-- configure diagnostics behaviour
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        update_in_insert = true,
        underline = false,
        virtual_text = false,
        signs = false
    }
)

-- highlight region after yanking
vim.api.nvim_create_autocmd('TextYankPost', {
    pattern = '*',
    group = vim.api.nvim_create_augroup('YankHighlight', {clear = true}),
    callback = function()
        vim.highlight.on_yank({higroup = 'IncSearch', timeout = 200})
    end
})

-- remember last position in files
vim.cmd [[ au BufReadPost * if line("'\"") >= 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif ]]
