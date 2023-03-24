-- Bootstrap lazy.nvim if needed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
   vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable',
      lazypath,
   }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
   { 'williamboman/mason.nvim', opts = {} },

   {
      'nvim-treesitter/nvim-treesitter',
      dependencies = {
         'nvim-treesitter/nvim-treesitter-textobjects',
      },
      config = function()
         pcall(require('nvim-treesitter.install').update { with_sync = true })
      end,
   },

   {
      'neovim/nvim-lspconfig',
      dependencies = {
         {
            'hrsh7th/nvim-cmp',
            dependencies = {
               'hrsh7th/cmp-nvim-lsp',
               'L3MON4D3/LuaSnip',
               'saadparwaiz1/cmp_luasnip'
            }
         },

         { 'williamboman/mason-lspconfig.nvim' },
         { 'j-hui/fidget.nvim',                opts = {} },
         { 'folke/neodev.nvim',                opts = {} },
      },
   },

   { 'mfussenegger/nvim-dap' },
   { 'rcarriga/nvim-dap-ui',    opts = {} },
   {
      'jay-babu/mason-nvim-dap.nvim',
      config = function()
      end
   },

   {
      'nvim-telescope/telescope.nvim',
      dependencies = {
         { 'nvim-lua/plenary.nvim' },
         {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
               return vim.fn.executable('make') == 1
            end,
         },
      }
   },

   {
      'EdenEast/nightfox.nvim',
      priority = 1000,
      config = function()
         vim.cmd.colorscheme('dayfox')
      end,
   },

   { 'folke/which-key.nvim',  opts = {} },

   {
      'lewis6991/gitsigns.nvim',
      opts = {
         signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '-' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
         },
      },
   },

   {
      'lukas-reineke/indent-blankline.nvim',
      opts = {
         char = '┊',
         show_trailing_blankline_indent = false,
      },
   },

   { 'numToStr/Comment.nvim', opts = {} },

   { 'tpope/vim-sleuth' },

   {
      'ellisonleao/glow.nvim',
      config = true,
      cmd = 'Glow',
      cond = function()
         return vim.fn.executable('glow') == 1
      end,
   },
})

local function setup_completion()
   local cmp = require('cmp')
   local luasnip = require('luasnip')

   luasnip.config.setup({})

   cmp.setup({
      snippet = {
         expand = function(args)
            luasnip.lsp_expand(args.body)
         end,
      },
      window = {
         completion = cmp.config.window.bordered(),
         documentation = cmp.config.window.bordered()
      },
      mapping = cmp.mapping.preset.insert({
         ['<C-u>'] = cmp.mapping.scroll_docs(-4),
         ['<C-d>'] = cmp.mapping.scroll_docs(4),
         ['<C-e>'] = cmp.mapping.abort(),
         ['<C-n'] = cmp.mapping(function(fallback)
            if cmp.visible() then
               cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
               luasnip.expand_or_jump()
            else
               fallback()
            end
         end, { 'i', 's' }),
         ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
               cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
               luasnip.jump(-1)
            else
               fallback()
            end
         end, { 'i', 's' }),
      }),
      sources = {
         { name = 'nvim_lsp' },
         { name = 'luasnip' },
      },
   })
end

local function setup_dap()
   local dap = require('dap')
   local mason_nvim_dap = require('mason-nvim-dap')
   local which_key = require('which-key')

   mason_nvim_dap.setup({
      automatic_setup = true
   })
   mason_nvim_dap.setup_handlers({})

   which_key.register({
      ['<leader>d'] = { name = '+Debug Adapter Protocol' }
   })
   vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Breakpoint toggle' })
   vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Continue' })
   vim.keymap.set('n', '<leader>dC', dap.reverse_continue, { desc = 'Reverse continue' })
   vim.keymap.set('n', '<leader>dp', dap.pause, { desc = 'Pause' })
   vim.keymap.set('n', '<leader>dg', dap.run_to_cursor, { desc = 'Run to cursor' })
   vim.keymap.set('n', '<leader>dG', dap.goto_, { desc = 'Goto line' })
   vim.keymap.set('n', '<leader>dr', dap.restart, { desc = 'Restart' })
   vim.keymap.set('n', '<leader>dR', dap.run_last, { desc = 'Run last' })
   vim.keymap.set('n', '<leader>dt', dap.terminate, { desc = 'Terminate' })

   which_key.register({
      ['<leader>dB'] = { name = '+Breakpoints' }
   })
   vim.keymap.set('n', '<leader>dBc', dap.clear_breakpoints, { desc = 'Clear all' })
   vim.keymap.set('n', '<leader>dBl', dap.list_breakpoints, { desc = 'List' })

   which_key.register({
      ['<leader>ds'] = { name = '+Step' }
   })
   vim.keymap.set('n', '<leader>dsb', dap.step_back, { desc = 'Step back' })
   vim.keymap.set('n', '<leader>dsi', dap.step_into, { desc = 'Step into' })
   vim.keymap.set('n', '<leader>dso', dap.step_over, { desc = 'Step over' })
   vim.keymap.set('n', '<leader>dsO', dap.step_out, { desc = 'Step out' })
end

local function setup_telescope()
   local telescope = require('telescope')
   local builtin = require('telescope.builtin')
   local which_key = require('which-key')

   telescope.setup({})
   pcall(telescope.load_extension, 'fzf')

   which_key.register({
      ['<leader>f'] = { name = '+Fuzzy find' }
   })

   vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
   vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })
   vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Files' })
   vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Grep' })
   vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help' })
   vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
   vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = 'Old Files' })
   vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'References' })
   vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Document Symbols' })
   vim.keymap.set('n', '<leader>fS', builtin.lsp_dynamic_workspace_symbols, { desc = 'Workspace Symbols' })
   vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Grep Current Word' })
   vim.keymap.set('n', '<leader>f/', builtin.current_buffer_fuzzy_find, { desc = 'Current Buffer Search' })
end

local function setup_lsp()
   --  This function gets run when an LSP connects to a particular buffer
   --  and is needed because the vim.lsp.buf functions need the buffer number
   local on_attach = function(_, bufnr)
      local which_key = require('which-key')
      which_key.register({
         ['<leader>l'] = { name = '+Language Server Protocol' }
      })

      vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'Code Action' })
      vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, { buffer = bufnr, desc = 'Definition' })
      vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, { buffer = bufnr, desc = 'Declaration' })
      vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, { buffer = bufnr, desc = 'Format' })
      vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover Documentation' })
      vim.keymap.set('n', '<leader>lH', vim.lsp.buf.signature_help, { buffer = bufnr, desc = 'Signature Documentation' })
      vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, { buffer = bufnr, desc = 'Implementation' })
      vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, { desc = 'References' })
      vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename, { buffer = bufnr, desc = 'Rename' })
      vim.keymap.set('n', '<leader>ls', vim.lsp.buf.document_symbol, { buffer = bufnr, desc = 'Document Symbols' })
      vim.keymap.set('n', '<leader>lS', vim.lsp.buf.workspace_symbol, { buffer = bufnr, desc = 'Workspace Symbols' })
      vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition, { buffer = bufnr, desc = 'Type Definition' })

      which_key.register({
         ['<leader>lw'] = { name = '+Workspace' }
      })
      vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, { buffer = bufnr, desc = 'Add Folder' })
      vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, { buffer = bufnr, desc = 'Remove Folder' })
      vim.keymap.set('n', '<leader>lwl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders)) end,
         { buffer = bufnr, desc = 'List Folders' })
   end

   -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
   local capabilities = vim.lsp.protocol.make_client_capabilities()
   capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

   local servers = {
      clangd = {},
      lua_ls = {
         Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
         },
      },
   }

   require('mason-lspconfig').setup({
      ensure_installed = vim.tbl_keys(servers),
   })
   require('mason-lspconfig').setup_handlers({
      function(server_name)
         require('lspconfig')[server_name].setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name],
         }
      end,
   })
end

local function setup_treesitter()
   -- Use treesitter for code folding
   vim.opt.foldmethod = 'expr'
   vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

   require('nvim-treesitter.configs').setup({
      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
         'c',
         'cpp',
         'lua',
         'help',
         'vim'
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true, disable = { 'python' } },
      incremental_selection = {
         enable = true,
         keymaps = {
            init_selection = 'gnn',
            node_incremental = 'grn',
            scope_incremental = 'grc',
            node_decremental = 'grm',
         },
      },
      textobjects = {
         select = {
            enable = true,
            lookahead = true,
            keymaps = {
               ['aa'] = '@parameter.outer',
               ['ia'] = '@parameter.inner',
               ['af'] = '@function.outer',
               ['if'] = '@function.inner',
               ['ac'] = '@class.outer',
               ['ic'] = '@class.inner',
            },
         },
         move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
               [']m'] = '@function.outer',
               [']]'] = '@class.outer',
            },
            goto_next_end = {
               [']M'] = '@function.outer',
               [']['] = '@class.outer',
            },
            goto_previous_start = {
               ['[m'] = '@function.outer',
               ['[['] = '@class.outer',
            },
            goto_previous_end = {
               ['[M'] = '@function.outer',
               ['[]'] = '@class.outer',
            },
         },
         swap = {
            enable = true,
            swap_next = {
               ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
               ['<leader>A'] = '@parameter.inner',
            },
         },
      },
   })
end

setup_completion()
setup_dap()
setup_lsp()
setup_telescope()
setup_treesitter()
