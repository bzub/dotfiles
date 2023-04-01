local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  { 'williamboman/mason.nvim',
    module = false,
    lazy = false,
    config = function()
      require("mason").setup()
    end
  },

  { 'williamboman/mason-lspconfig.nvim',
    module = false,
    lazy = false,
    dependencies = {
      'mason.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = {
          'bashls',
          'dockerls',
          'golangci_lint_ls',
          'gopls',
          'jsonls',
          'lua_ls',
          'marksman', -- Markdown
          -- 'spectral', -- OpenAPI
          'taplo',    -- TOML
          'terraformls',
          'vimls',
          'yamlls',
        }
      }
    end
  },

  { 'nvim-treesitter/nvim-treesitter',
    module = false,
    lazy = false,
    version = false,
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-context',
    },
    config = function()
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        highlight = { enable = true },
        incremental_selection = { enable = true },
        indent = { enable = true },
        context = { enable = true },
      }

      vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.o.foldmethod = 'expr'

      -- Octo support
      vim.treesitter.language.register('markdown', 'octo')
    end
  },

  { 'neovim/nvim-lspconfig',
    module = false,
    lazy = false,
    config = function()
      -- Mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      local opts = { noremap = true, silent = true }
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(_, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.MiniCompletion.completefunc_lsp')
        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
      end

      -- Use a loop to conveniently call 'setup' on multiple servers and
      -- map buffer local keybindings when the language server attaches
      local servers = { 'bashls', 'gopls', 'html', 'jsonls', 'marksman', 'golangci_lint_ls' }
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = on_attach,
        }
      end

      -- yaml
      require 'lspconfig'.yamlls.setup {
        on_attach = on_attach,
        settings = {
          redhat = {
            telemetry = {
              enabled = false
            },
          },
          yaml = {
            -- yamlVersion = '1.2',
            validate = true,
            hover = true,
            completion = true,
            disableAdditionalProperties = true,
            -- schemaStore = {
            --   enable = false,
            -- },
            format = {
              enable = false,
            },
          },
        },
      }

      require 'lspconfig'.lua_ls.setup {
        on_attach = on_attach,
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      }
    end,
  },

  { 'echasnovski/mini.nvim',
    module = false,
    lazy = false,
    version = false,
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require 'mini.ai'.setup {}
      -- require('mini.animate').setup({})
      require 'mini.bufremove'.setup {}
      require 'mini.comment'.setup {}
      require 'mini.completion'.setup {
        lsp_completion = {
          source_func = 'omnifunc',
          auto_setup = false,
        },
        mappings = {
          force_twostep = '<C-Space>',
          force_fallback = '<A-Space>',
        },
      }
      require 'mini.fuzzy'.setup {}
      require 'mini.indentscope'.setup({
        draw = {
          delay = 100,
          animation = require 'mini.indentscope'.gen_animation.cubic({
            easing = 'in',
            duration = 800,
            unit = 'total',
          })
        },
      })
      require 'mini.jump'.setup {}
      require 'mini.jump2d'.setup {}
      local map = require('mini.map')
      map.setup {
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.gitsigns(),
          map.gen_integration.diagnostic(),
        },
        symbols = {
          encode = map.gen_encode_symbols.shade('1x2'),
          scroll_line = '▶',
          scroll_view = '┋',
        },
        window = {
          focusable = false,
          side = 'right',
          show_integration_count = true,
          width = 20,
          winblend = 25,
        },
      }
      vim.keymap.set('n', '<Leader>mc', MiniMap.close)
      vim.keymap.set('n', '<Leader>mf', MiniMap.toggle_focus)
      vim.keymap.set('n', '<Leader>mo', MiniMap.open)
      vim.keymap.set('n', '<Leader>mr', MiniMap.refresh)
      vim.keymap.set('n', '<Leader>ms', MiniMap.toggle_side)
      vim.keymap.set('n', '<Leader>mt', MiniMap.toggle)
      require 'mini.misc'.setup {}
      require 'mini.pairs'.setup {}
      require 'mini.statusline'.setup({
        -- Global statusline
        set_vim_settings = false,
        content = {
          active = function()
            local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
            local git           = MiniStatusline.section_git({ trunc_width = 75 })
            local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75 })
            local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
            local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
            local location      = MiniStatusline.section_location({ trunc_width = 75 })

            return MiniStatusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { location } },
            })
          end
        }
      })
      require 'mini.surround'.setup {}
      require 'mini.tabline'.setup({
        tabpage_section = 'right',
      })
      require 'mini.trailspace'.setup {}
    end
  },

  { 'akinsho/toggleterm.nvim',
    module = false,
    lazy = false,
    config = function()
      require("toggleterm").setup {
        auto_scroll = false,
        persist_mode = true, -- if set to true the previous terminal mode will be remembered
        shade_filetypes = { 'toggleterm' },
        open_mapping = [[<M-Space>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
        close_on_exit = true, -- close the terminal window when the process exits
        size = function(term)
          if term.direction == "horizontal" then
            return 40
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
      }
      local toggleterm = require'toggleterm'
      local toggle_with_direction = function(direction)
        return function()
          toggleterm.toggle(vim.v.count, nil, nil, direction)
        end
      end
      local opts = { noremap = true, silent = false }
      vim.keymap.set({ "n", "t" }, [[�ñ]], toggle_with_direction(nil), opts) -- F1
      vim.keymap.set({ "n", "t" }, [[�ò]], toggle_with_direction("float"), opts) -- F2
    end
  },

  { 'samjwill/nvim-unception' },

  { 'crispgm/nvim-go',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('go').setup {
        auto_lint = false,
        formatter = "lsp",
        maintain_cursor_pos = true,
      }
    end
  },

  { 'folke/neodev.nvim' },

  { 'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup({
        current_line_blame = false,
        signcolumn         = false, -- Toggle with `:Gitsigns toggle_signs`
        numhl              = true, -- Toggle with `:Gitsigns toggle_numhl`
        linehl             = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff          = false, -- Toggle with `:Gitsigns toggle_word_diff`
        on_attach          = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, { expr = true })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      })
    end
  },

  { 'tpope/vim-eunuch' }, -- wrappers UNIX commands
  { 'tpope/vim-abolish' },
  { 'tpope/vim-unimpaired' },
  { 'tpope/vim-sleuth' },

  { "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        manual_mode = true,
        show_hidden = false, -- TODO: Open issue to customize picker, etc. I want hidden files but not .git.
        silent_chdir = false,
      })
    end
  },

  -- telescope
  { 'nvim-telescope/telescope.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-github.nvim' },
      { 'nvim-telescope/telescope-ghq.nvim' },
      { 'echasnovski/mini.nvim' },
      { 'tami5/sqlite.lua' },
      { 'nvim-telescope/telescope-smart-history.nvim' },
      { 'nvim-telescope/telescope-frecency.nvim' },
      { 'ahmedkhalf/project.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'pwntester/octo.nvim' },
    },

    config = function()
      local actions = {}
      actions.smart_send_to_qflist = function(prompt_bufnr)
        require('telescope.actions').smart_send_to_qflist(prompt_bufnr)
        require('telescope.actions').open_qflist(prompt_bufnr)
      end
      actions.smart_add_to_qflist = function(prompt_bufnr)
        require('telescope.actions').smart_add_to_qflist(prompt_bufnr)
        require('telescope.actions').open_qflist(prompt_bufnr)
      end

      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          file_sorter = require('mini.fuzzy').get_telescope_sorter,
          generic_sorter = require('mini.fuzzy').get_telescope_sorter,
          winblend = 0,
          sorting_strategy = "descending",
          layout_strategy = "vertical",
          path_display = {
            "smart",
          },
          cache_picker = {
            num_pickers = 20,
            limit_entries = 1000,
          },
          preview = {
            hide_on_startup = false,
          },
          -- mappings = {
          --   i = {
          --     ["<M-q>"] = false,
          --     ["<M-C-Q>"] = actions.smart_send_to_qflist,
          --     ["<M-C-A>"] = actions.smart_add_to_qflist,
          --   },
          --   n = {
          --     ["<M-q>"] = false,
          --     ["<M-C-Q>"] = 'smart_send_to_qflist',
          --     ["<M-C-A>"] = 'smart_add_to_qflist',
          --   },
          -- },
        },
        builtin = {
          builtin = {
            include_extensions = true,
          },
          oldfiles = {
            only_cwd = true,
          },
        },
        pickers = {
          lsp_references = {
            show_line = true,
            trim_text = true,
            fname_width = 80,
          },
        },
        extensions = {
          frecency = {
            default_workspace = 'CWD',
            ignore_patterns = {
              '*.git/*',
              '*/vendor/*',
            },
            show_unindexed = false,
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {},
          },
          undo = {
            side_by_side = true,
            layout_strategy = "vertical",
            layout_config = {
              preview_height = 0.8,
            },
          },
        },
      }

      local extensions = {
        'gh',
        'ghq',
        'frecency',
        'projects',
        'ui-select',
        'file_browser',
        'octo',
      }

      for _, extension in pairs(extensions) do
        telescope.load_extension(extension)
      end

      vim.keymap.set('n', '<Leader><Space>', '<Cmd>Telescope<cr>')
      vim.keymap.set('n', '<Leader>p', '<Cmd>Telescope projects<cr>')
      vim.keymap.set('n', '<Leader>ff', '<Cmd>Telescope frecency<cr>')
      vim.keymap.set('n', '<Leader>fb', '<Cmd>Telescope file_browser<cr>')
      vim.keymap.set('n', '<Leader>o', '<Cmd>Telescope oldfiles<cr>')
      vim.keymap.set('n', '<Leader>b', '<Cmd>Telescope buffers<cr>')
      vim.keymap.set('n', '<Leader>gs', '<Cmd>Telescope git_status<cr>')
      vim.keymap.set('n', '<Leader>gb', '<Cmd>Telescope git_branches<cr>')
      vim.keymap.set('n', '<Leader>gc', '<Cmd>Telescope git_commits<cr>')
      vim.keymap.set('n', '<Leader>gf', '<Cmd>Telescope git_files<cr>')
    end
  },

  { 'pwntester/octo.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require "octo".setup()
    end
  },

  { "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
      }
    end
  },

  { 'debugloop/telescope-undo.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require("telescope").load_extension("undo")
    end,
  },

  -- { 'ellisonleao/gruvbox.nvim',
  --   version = false,
  --   config = function()
  --     require("gruvbox").setup({
  --       undercurl = true,
  --       underline = true,
  --       bold = true,
  --       italic = false,
  --       strikethrough = true,
  --       invert_selection = false,
  --       invert_signs = false,
  --       invert_tabline = false,
  --       invert_intend_guides = false,
  --       inverse = true, -- invert background for search, diffs, statuslines and errors
  --       contrast = "soft", -- can be "hard", "soft" or empty string
  --       palette_overrides = {
  --           bright_green = "#990000",
  --       },
  --       overrides = {},
  --       dim_inactive = false,
  --       transparent_mode = false,
  --     })
  --   end
  -- },

  { 'sainnhe/gruvbox-material',
  },
}

require("lazy").setup(plugins)
