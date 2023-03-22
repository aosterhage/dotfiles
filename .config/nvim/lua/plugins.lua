-- Bootstrap lazy.nvim if needed
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Install any desired plugins
require('lazy').setup({
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Completion support
      {
        'hrsh7th/nvim-cmp',
        dependencies = {
          'hrsh7th/cmp-nvim-lsp',
          'L3MON4D3/LuaSnip',
          'saadparwaiz1/cmp_luasnip'
        }
      },

      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim',          opts = {} },
      { 'williamboman/mason-lspconfig.nvim' },

      -- Useful status updates for LSP
      { 'j-hui/fidget.nvim',                opts = {} },

      -- Automatically setup lua lsp with config and runtime directories
      { 'folke/neodev.nvim',                opts = {} },
    },
  },

  -- Fuzzy finder for everything
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

  -- Colorscheme
  {
    'sainnhe/sonokai',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('sonokai')
    end,
  },

  -- Show pending keybinds
  { 'folke/which-key.nvim',  opts = {} },

  -- Add git related signs to the gutter
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

  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
  },

  -- Comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Detect tabstop and shiftwidth automatically
  { 'tpope/vim-sleuth' },

  -- Markdown preview
  {
    'ellisonleao/glow.nvim',
    config = true,
    cmd = 'Glow',
    cond = function()
      return vim.fn.executable('glow') == 1
    end,
  },
})

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
  local which_key = require('which-key')
  which_key.register({
    ['<leader>l'] = { name = '+LSP' }
  })

  --  This function gets run when an LSP connects to a particular buffer
  --  and is needed because the vim.lsp.buf functions need the buffer number
  local on_attach = function(_, bufnr)
    vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { buffer = bufnr, desc = 'Code Action' })
    vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, { buffer = bufnr, desc = 'Defintion' })
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
    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true, disable = { 'python' } },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
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
    mapping = cmp.mapping.preset.insert({
      ['<C-u>'] = cmp.mapping.scroll_docs(4),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<Tab>'] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
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

-- Setup any needed plugins
setup_completion()
setup_lsp()
setup_telescope()
setup_treesitter()
