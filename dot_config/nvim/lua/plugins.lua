return require('packer').startup({ function(use)
  use { 'wbthomason/packer.nvim' }

  use { 'sainnhe/gruvbox-material' }

  use { 'ellisonleao/glow.nvim' }

  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

  use { 'crispgm/nvim-go',
    requires = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('go').setup{
        auto_lint = true,
        lint_prompt_style = 'vt',
      }
    end
  }

  use { 'TimUntersberger/neogit',
    branch = 'master',
    requires = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
    },
    config = function()
      require('neogit').setup({
        disable_commit_confirmation = true,
        integrations = {
          diffview = true,
        },
      })
    end
  }

  use { 'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    run = ':TSUpdate',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor',
      'nvim-treesitter/nvim-treesitter-context',
      'nvim-treesitter/nvim-treesitter-textobjects'
    },
    config = function()
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        highlight = { enable = true },
        incremental_selection = { enable = true },
        textobjects = {
          enable = true,
          set_jumps = true,
        },
        indent = { enable = true },
        context = { enable = true },
        refactor = {
          highlight_definitions = {
            enable = true,
            clear_on_cursor_move = true,
          },
          highlight_current_scope = { enable = false },
          smart_rename = {
            enable = true,
            keymaps = {
              smart_rename = "grr",
            },
          },
          navigation = {
            enable = true,
            keymaps = {
              -- TODO: need to disable this default keymap?
              -- goto_definition = "gnd",
              -- goto_definition_lsp_fallback = "gnd",
              list_definitions = "gnD",
              list_definitions_toc = "gO",
              goto_next_usage = "<a-*>",
              goto_previous_usage = "<a-#>",
            },
          },
        },
      }

      vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
      vim.o.foldmethod = 'expr'

      -- Octo support
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.markdown.filetype_to_parsername = "octo"
    end
  }

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
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
      end

      -- Use a loop to conveniently call 'setup' on multiple servers and
      -- map buffer local keybindings when the language server attaches
      local servers = { 'bashls', 'gopls', 'html', 'jsonls' }
      for _, lsp in pairs(servers) do
        require('lspconfig')[lsp].setup {
          on_attach = on_attach,
          flags = {
            -- This will be the default in neovim 0.7+
            debounce_text_changes = 150,
          }
        }
      end

      -- yaml
      require 'lspconfig'.yamlls.setup {
        on_attach = on_attach,
        flags = {
          -- This will be the default in neovim 0.7+
          debounce_text_changes = 150,
        },
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
            -- disableDefaultProperties = true,
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

      -- Lua
      require 'lspconfig'.sumneko_lua.setup {
        on_attach = on_attach,
        flags = {
          -- This will be the default in neovim 0.7+
          debounce_text_changes = 150,
        },
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

  use 'tpope/vim-unimpaired'
  use 'tpope/vim-abolish'
  use 'tpope/vim-sleuth'
  use 'nvim-lua/plenary.nvim'

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

          -- Actions
          map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
          map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line { full = true } end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      })
    end
  }

  use 'tpope/vim-eunuch' -- wrappers UNIX commands

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
  use {
    'nvim-telescope/telescope.nvim',
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

      require 'telescope'.setup {
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
          lsp_references =  {
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
        },
      }

      require 'telescope'.load_extension 'gh'
      require 'telescope'.load_extension 'ghq'
      require 'telescope'.load_extension 'frecency'
      require 'telescope'.load_extension 'projects'
      require 'telescope'.load_extension 'ui-select'
      require 'telescope'.load_extension 'file_browser'
      require 'telescope'.load_extension 'packer'
      require 'telescope'.load_extension 'termfinder'
      require 'telescope'.load_extension 'octo'

      mapall('<Leader><Space>', '<Cmd>Telescope<cr>')
      mapall('<Leader>p', '<Cmd>Telescope projects<cr>')
      mapall('<Leader>f', '<Cmd>Telescope frecency<cr>')
      mapall('<Leader>g', '<Cmd>Telescope ghq list<cr>')
      mapall('<Leader>o', '<Cmd>Telescope oldfiles<cr>')
      mapall('<Leader>b', '<Cmd>Telescope buffers<cr>')
      mapall('<Leader>t', '<Cmd>Telescope termfinder<cr>')
    end
  }

  use { "numToStr/FTerm.nvim",
    config = function()
      -- TODO: Move this out to be used generally.
      local has_key = function(something, key)
        return something[key] ~= nil
      end
      if not has_key(_G, "Bzub") then
        _G.Bzub = {}
      end

      local term_config = {
        cmd = "zsh",
        hl = 'NormalHard',
        blend = 0,
        on_exit = function(job_id, _, _)
          for i, _ in ipairs(_G.Bzub.Terms) do
            if _G.Bzub.Terms[i].job_id_copy == job_id then
              table.remove(_G.Bzub.Terms, i)
              if _G.Bzub.CurrentTerm > table.maxn(_G.Bzub.Terms) then
                _G.Bzub.CurrentTerm = table.maxn(_G.Bzub.Terms)
              end
            end
          end
        end,
      }

      -- Initialize global data
      if not has_key(_G.Bzub, "Terms") then
        _G.Bzub.Terms = {}
      end
      if not has_key(_G.Bzub, "fterm") then
        _G.Bzub.fterm = require("FTerm")
      end

      local new_term = function()
        local new_idx = table.maxn(_G.Bzub.Terms) + 1
        local new_term = _G.Bzub.fterm:new(term_config):setup(term_config)
        new_term.term_idx = new_idx
        table.insert(_G.Bzub.Terms, new_term)
        _G.Bzub.CurrentTerm = new_idx
        return new_idx
      end

      local get_term = function(term_idx)
        if not has_key(_G.Bzub.Terms, term_idx) then
          return nil
        end
        return _G.Bzub.Terms[term_idx]
      end

      local current_term_idx = function()
        if not has_key(_G.Bzub, "CurrentTerm") or get_term(_G.Bzub.CurrentTerm) == nil then
          new_term()
        end
        return _G.Bzub.CurrentTerm
      end

      local current_term = function()
        return _G.Bzub.Terms[current_term_idx()]
      end

      local ensure_job_id_copy = function(term_idx)
        local term = get_term(term_idx)
        if term ~= nil and term.terminal ~= nil then
          term.job_id_copy = term.terminal
        end
        return term
      end

      _G.Bzub.ToggleTerm = function()
        local term = current_term():toggle()
        ensure_job_id_copy(term.term_idx)
        return term
      end

      local close_all_terms = function()
        for i, _ in ipairs(_G.Bzub.Terms) do
          ensure_job_id_copy(i)
          _G.Bzub.Terms[i]:close()
        end
      end

      local open_term = function(term_idx)
        close_all_terms()
        _G.Bzub.CurrentTerm = term_idx
        return get_term(term_idx):open()
      end

      _G.Bzub.NewTerm = function()
        return open_term(new_term())
      end

      _G.Bzub.NextTerm = function()
        local old_idx = current_term_idx()
        local new_idx = old_idx + 1
        if new_idx > table.maxn(_G.Bzub.Terms) then
          new_idx = 1
        end
        open_term(new_idx)
      end

      _G.Bzub.PreviousTerm = function()
        local old_idx = current_term_idx()
        local new_idx = old_idx - 1
        if new_idx < 1 then
          new_idx = table.maxn(_G.Bzub.Terms)
        end
        open_term(new_idx)
      end

      mapall('<M-C-T>', '<CMD>lua _G.Bzub.ToggleTerm(vim.api.nvim_get_current_tabpage())<CR>')
      map('t', '<M-C-N>', '<CMD>lua _G.Bzub.NewTerm()<CR>')
      map('t', '<M-C-]>', '<CMD>lua _G.Bzub.NextTerm()<CR>')
      map('t', '<M-Esc>', '<CMD>lua _G.Bzub.PreviousTerm()<CR>')
    end,
  }

  use {
    'pwntester/octo.nvim',
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
      require 'mini.bufremove'.setup {}
      require 'mini.comment'.setup {}
      require 'mini.cursorword'.setup {}
      require 'mini.fuzzy'.setup {}
      require 'mini.indentscope'.setup({
        draw = {
          delay = 100,
          animation = require 'mini.indentscope'.gen_animation(
            'cubicIn',
            {
              duration = 500,
              unit = 'total',
            }
          ),
        },
      })
      require 'mini.jump'.setup {}
      require 'mini.jump2d'.setup {}
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

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
      }
    end
  }
end,
  config = {
    display = {
      open_fn = require('packer.util').float,
    },
  },
})
