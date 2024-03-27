-- reduce startup time
vim.loader.enable()

-- set leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = vim.g.mapleader

-- hide '~' at buffer end
vim.opt.fillchars:append({ eob = ' ' })

-- show numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- set case insensitiveness, alter with \C
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- make undo history everlasting
vim.opt.undofile = true

-- appropriate indent on new line
vim.opt.smartindent = true
vim.opt.breakindent = false

-- live preview substitutions
vim.opt.inccommand = 'split'

-- define statusline behaviour
vim.opt.laststatus = 2

-- number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

-- set proper tab width
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- number of spaces to use for indentation
vim.opt.shiftwidth = 4

-- use the appropriate number of spaces to insert a <Tab>
vim.opt.expandtab = true

-- block swap file creation
vim.opt.swapfile = false

-- define languages for spelling feature
vim.opt.spelllang = { 'en_us', 'it' }

-- adjusts default color groups
vim.opt.background = 'dark'

-- enables 24-bit RGB color
vim.opt.termguicolors = true

-- highlight the line on which the cursor in on
vim.opt.cursorline = true

-- keep block cursor style in insert mode
vim.opt.guicursor = 'i:block'

-- always show signcolumn
vim.opt.signcolumn = 'auto'

-- highlight column that indicate maximum text width
vim.opt.colorcolumn = '80'

-- put a message on the last line showing current mode
vim.opt.showmode = true

-- splits initial position
vim.opt.splitright = true
vim.opt.splitbelow = true

-- customize completion menu behaviour
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect' }

-- limit showed completion options
vim.opt.pumheight = 5

-- number of screen lines to use for the command-line window
vim.opt.cmdwinheight = 5

-- exit insert mode
vim.keymap.set('i', '<c-c>', '<esc>')

-- move selected text horizontally
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<', '<gv')

-- center search results
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '*', '*zz')
vim.keymap.set('n', '#', '#zz')

-- exit terminal mode
-- vim.keymap.set('t', '<esc><esc>', '<C-\\><C-n>')

-- deal with line wrap
vim.keymap.set('n', 'j', 'v:count == 0 ? "gj" : "j"', { expr = true })
vim.keymap.set('n', 'k', 'v:count == 0 ? "gk" : "k"', { expr = true })

-- universal diagnostics keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- highlight region after yanking
vim.api.nvim_create_autocmd('TextYankPost', {
    pattern = '*',
    group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
    end,
})

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
    -- detect tabs automatically
    'tpope/vim-sleuth',

    -- git wrapper
    'tpope/vim-fugitive',

    -- edit surroundings with textobjects
    'tpope/vim-surround',

    -- replace inside textobject with register content using 'gr'
    'vim-scripts/ReplaceWithRegister',

    -- multicursor editing
    'mg979/vim-visual-multi',

    -- undo tree view
    'mbbill/undotree',

    { -- all-around helper for latex
        'lervag/vimtex',
        config = function() vim.g.vimtex_view_method = 'zathura' end,
    },

    -- comment region/lines
    { 'numToStr/Comment.nvim', opts = {} },

    { -- colorscheme
        'ramojus/mellifluous.nvim',
        priority = 1000,
        init = function()
            require('mellifluous').setup({})
            vim.cmd.colorscheme('mellifluous')
            vim.cmd.hi('Comment gui=none')
        end,
    },

    { -- enhance textobjects functionalities
        'echasnovski/mini.ai',
        version = '*',
        opts = {},
    },

    { -- highlight, edit and navigate code
        'nvim-treesitter/nvim-treesitter',
        main = 'nvim-treesitter.configs',
        build = ':TSUpdate',
        dependencies = {
            'andymass/vim-matchup',
            config = function()
                vim.g.matchup_matchparen_offscreen = { method = 'popup' }
                vim.cmd.hi('MatchWord gui=none')
            end,
        },
        opts = {
            ensure_installed = {
                'bash',
                'c',
                'html',
                'lua',
                'markdown',
                'vim',
                'vimdoc',
                'comment',
            },
            auto_install = true,
            indent = { enable = true },
            highlight = { enable = true },
            matchup = {
                enable = true,
                disable_virtual_text = true,
                include_match_words = true,
            },
        },
    },

    { -- file system navigation
        'stevearc/oil.nvim',
        config = function()
            local oil = require('oil')
            oil.setup({
                delete_to_trash = true,
                columns = { 'mtime', 'size', 'permissions' },
                prompt_save_on_select_new_entry = false,
                skip_confirm_for_simple_edits = true,
                lsp_file_methods = { autosave_changes = false },
            })

            -- open parent directory
            vim.keymap.set('n', '-', oil.open)
        end,
    },

    { -- adds git related signs to the gutter
        'lewis6991/gitsigns.nvim',
        opts = {
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },

    { -- completion engine
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
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

            -- don't insert selected option
            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            -- load set of snippets
            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<c-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<c-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<c-y>'] = cmp.mapping.confirm({ select = true }),
                    ['<c-d>'] = cmp.mapping.scroll_docs(4),
                    ['<c-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-e>'] = cmp.mapping.abort(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                }, { name = 'buffer' }),
            })
        end,
    },

    { -- fzf integration
        'ibhagwan/fzf-lua',
        config = function()
            local fzf = require('fzf-lua')
            fzf.setup({
                'fzf-vim',
                winopts = {
                    split = '7split belowright new',
                },
            })
            fzf.directories = function() fzf.files({ cmd = 'fd -t d' }) end
            fzf.rg = function()
                fzf.live_grep_native({ winopts = { split = 'belowright new' } })
            end

            vim.keymap.set('n', '<c-h>f', fzf.files)
            vim.keymap.set('n', '<c-h>d', fzf.directories)
            vim.keymap.set('n', '<c-h>r', fzf.resume)
            vim.keymap.set('n', '<c-h>h', fzf.builtin)
            vim.keymap.set('n', '<c-h>g', fzf.rg)
            vim.keymap.set('n', '<c-h>b', fzf.buffers)
            vim.keymap.set('v', '<c-h>v', fzf.grep_visual)
        end,
    },

    { -- format tool
        'stevearc/conform.nvim',
        opts = {
            notify_on_error = true,
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'autopep8', 'black' },
                javascript = { { 'prettierd', 'prettier' } },
            },
        },
    },

    { -- lsp configuration
        'neovim/nvim-lspconfig',
        dependencies = {
            -- automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'WhoIsSethDaniel/mason-tool-installer.nvim',
        },
        config = function()
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup(
                    'lsp-config',
                    { clear = true }
                ),
                callback = function(event)
                    local client =
                        vim.lsp.get_client_by_id(event.data.client_id)
                    client.server_capabilities.semanticTokensProvider = nil

                    local fzf = require('fzf-lua')
                    local opts = { buffer = event.buf, remap = false }

                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set(
                        'n',
                        '<c-k>',
                        vim.lsp.buf.signature_help,
                        opts
                    )
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

                    vim.keymap.set('n', 'gd', fzf.lsp_definitions, opts)
                    vim.keymap.set('n', 'gR', fzf.lsp_references, opts)
                    vim.keymap.set('n', 'gI', fzf.lsp_implementations, opts)
                    vim.keymap.set(
                        'n',
                        '<leader>ca',
                        fzf.lsp_code_actions,
                        opts
                    )
                    vim.keymap.set('n', '<leader>D', fzf.lsp_typedefs, opts)
                    vim.keymap.set(
                        'n',
                        '<leader>ds',
                        fzf.lsp_document_symbols,
                        opts
                    )
                    vim.keymap.set(
                        'n',
                        '<leader>ws',
                        fzf.lsp_live_workspace_symbols,
                        opts
                    )

                    vim.keymap.set(
                        'n',
                        '<leader>F',
                        function()
                            require('conform').format({ bufnr = event.buf })
                        end,
                        opts
                    )
                end,
            })

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = vim.tbl_deep_extend(
                'force',
                capabilities,
                require('cmp_nvim_lsp').default_capabilities()
            )

            local servers = {
                pyright = {},
                clangd = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    '${3rd}/luv/library',
                                    unpack(
                                        vim.api.nvim_get_runtime_file('', true)
                                    ),
                                },
                            },
                            completion = { callSnippet = 'Replace' },
                        },
                    },
                },
            }

            require('mason').setup()
            local ensure_installed = vim.tbl_keys(servers)
            vim.list_extend(ensure_installed, { 'stylua', 'autopep8' })
            require('mason-tool-installer').setup({
                ensure_installed = ensure_installed,
            })

            require('mason-lspconfig').setup({
                handlers = {
                    function(server_name)
                        local server = servers[server_name]
                        server.capabilities = vim.tbl_deep_extend(
                            'force',
                            {},
                            capabilities,
                            server.capabilities or {}
                        )
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            })
        end,
    },
}, {})

-- configure diagnostics behaviour
vim.lsp.handlers['textDocument/publishDiagnostics'] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = true,
        virtual_text = true,
        underline = false,
        signs = false,
    })

-- jump to last edit position on opening file
vim.api.nvim_create_autocmd('BufReadPost', {
    pattern = '*',
    callback = function()
        if
            vim.fn.line('\'"') > 1
            and vim.fn.line('\'"') <= vim.fn.line('$')
        then
            if not vim.fn.expand('%:p'):find('.git', 1, true) then
                vim.cmd('exe "normal! g\'\\""')
            end
        end
    end,
})
