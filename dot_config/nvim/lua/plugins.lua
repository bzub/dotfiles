return require('packer').startup({ function(use)
  use { 'wbthomason/packer.nvim' }

  use { 'samjwill/nvim-unception' }

  use { 'crispgm/nvim-go',
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('go').setup {
        auto_lint = true,
        lint_prompt_style = 'vt',
      }
    end
  }

  use { 'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    run = ':TSUpdate',
    requires = {
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
      local ft_to_parser = require "nvim-treesitter.parsers".filetype_to_parsername
      ft_to_parser.octo = "markdown"
    end
  }

  use "folke/neodev.nvim"

  use { 'neovim/nvim-lspconfig',
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
      local servers = { 'bashls', 'gopls', 'html', 'jsonls' }
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = on_attach,
        }
      end

      -- yaml
      require 'lspconfig'.yamlls.setup {
        on_attach = on_attach,
        settings = {
          yaml = {
            redhat = {
              telemetry = {
                enabled = false
              }
            },
            yamlVersion = '1.2',
            validate = true,
            hover = true,
            completion = true,
            disableAdditionalProperties = true,
            schemaStore = {
              enable = true,
            },
            format = {
              enable = false,
            },
          },
        },
      }

      require 'lspconfig'.sumneko_lua.setup {
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
  }

  use { 'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
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
  }

  use 'tpope/vim-eunuch' -- wrappers UNIX commands
  use 'tpope/vim-abolish'
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-sleuth'

  use { "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        manual_mode = true,
        show_hidden = false, -- TODO: Open issue to customize picker, etc. I want hidden files but not .git.
        silent_chdir = false,
      })
    end
  }

  -- telescope
  use { 'nvim-telescope/telescope.nvim',
    requires = {
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
      { 'nvim-telescope/telescope-packer.nvim' },
      { 'tknightz/telescope-termfinder.nvim' },
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
          mappings = {
            i = {
              ["<M-q>"] = false,
              ["<M-C-Q>"] = actions.smart_send_to_qflist,
              ["<M-C-A>"] = actions.smart_add_to_qflist,
            },
            n = {
              ["<M-q>"] = false,
              ["<M-C-Q>"] = 'smart_send_to_qflist',
              ["<M-C-A>"] = 'smart_add_to_qflist',
            },
          },
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
              '*.local/share/nvim/site/pack/*',
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
        'packer',
        'termfinder',
        'octo',
      }

      for _, extension in pairs(extensions) do
        telescope.load_extension(extension)
      end

      vim.keymap.set('n', '<Leader><Space>', '<Cmd>Telescope<cr>')
      vim.keymap.set('n', '<Leader>p', '<Cmd>Telescope projects<cr>')
      vim.keymap.set('n', '<Leader>f', '<Cmd>Telescope frecency<cr>')
      vim.keymap.set('n', '<Leader>o', '<Cmd>Telescope oldfiles<cr>')
      vim.keymap.set('n', '<Leader>b', '<Cmd>Telescope buffers<cr>')
      vim.keymap.set('n', '<Leader>t', '<Cmd>Telescope termfinder<cr>')
      vim.keymap.set('n', '<Leader>gs', '<Cmd>Telescope git_status<cr>')
      vim.keymap.set('n', '<Leader>gb', '<Cmd>Telescope git_branches<cr>')
      vim.keymap.set('n', '<Leader>gc', '<Cmd>Telescope git_commits<cr>')
      vim.keymap.set('n', '<Leader>gf', '<Cmd>Telescope git_files<cr>')
    end
  }

  use { 'akinsho/toggleterm.nvim',
    config = function()
      require("toggleterm").setup {
        persist_mode = true, -- if set to true the previous terminal mode will be remembered
        shade_filetypes = { 'toggleterm' },
        open_mapping = [[<C-Space>]],
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
    end
  }

  use { 'pwntester/octo.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require "octo".setup()
    end
  }

  use { 'echasnovski/mini.nvim',
    branch = 'main',
    requires = {
      'lewis6991/gitsigns.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require 'mini.ai'.setup {}
      require('mini.animate').setup({})
      require 'mini.bufremove'.setup {}
      require 'mini.comment'.setup {}
      require 'mini.completion'.setup {}
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
  }

  use { "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
      }
    end
  }

  use { 'debugloop/telescope-undo.nvim',
    requires = { 'nvim-telescope/telescope.nvim' },
    config = function()
      require("telescope").load_extension("undo")
    end,
  }
end,
  config = {
    display = {
      open_fn = require('packer.util').float,
    },
  },
})
