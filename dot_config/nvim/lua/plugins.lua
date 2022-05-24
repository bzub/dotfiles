return require('packer').startup({ function(use)
  use { 'wbthomason/packer.nvim' }

  use { 'sainnhe/gruvbox-material',
    config = function()
      vim.cmd([[
        function! s:gruvbox_material_custom() abort
          let l:palette = gruvbox_material#get_palette('hard', 'material')
          call gruvbox_material#highlight('DarkTerminal', l:palette.fg0, l:palette.bg0)
        endfunction
        
        augroup GruvboxMaterialCustom
          autocmd!
          autocmd ColorScheme gruvbox-material call s:gruvbox_material_custom()
        augroup END
      ]])
      vim.g.gruvbox_material_background = 'medium'
      vim.g.gruvbox_material_enable_italic = 1
      vim.g.gruvbox_material_enable_bold = 1
    end
  }

  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

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
    },
    config = function()
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = "all",
        highlight = { enable = true },
        incremental_selection = { enable = true },
        textobjects = { enable = true },
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

      -- Octo support
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.markdown.filetype_to_parsername = "octo"
    end
  }

  use 'neovim/nvim-lspconfig'

  use { 'ray-x/go.nvim',
    config = function()
      require('go').setup()
    end
  }

  use 'tpope/vim-unimpaired'
  use 'tpope/vim-abolish'
  use 'tpope/vim-sleuth'
  use 'nvim-lua/plenary.nvim'

  use { 'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup({
        current_line_blame = false
      })
    end
  }

  use 'tpope/vim-eunuch' -- wrappers UNIX commands

  use { "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {}
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
    },

    config = function()
      require 'telescope'.setup {
        defaults = {
          file_sorter = require('mini.fuzzy').get_telescope_sorter,
          generic_sorter = require('mini.fuzzy').get_telescope_sorter,
          winblend = 0,
          sorting_strategy = "descending",
          layout_strategy = "center",
          path_display = {},
          mappings = {
            i = {
              ["<C-Down>"] = require('telescope.actions').cycle_history_next,
              ["<C-Up>"] = require('telescope.actions').cycle_history_prev,
            },
          },
          history = {
            path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
            limit = 1000,
          },
          cache_picker = {
            num_pickers = 20,
            limit_entries = 1000,
          },
          preview = {
            hide_on_startup = true,
          },
        },
        builtin = {
          oldfiles = {
            only_cwd = true,
          },
        },
      }

      require 'telescope'.load_extension 'ghq'
      require 'telescope'.load_extension 'smart_history'
      require 'telescope'.load_extension 'frecency'
      require 'telescope'.load_extension 'projects'

      mapall('<Leader><Space>', ':Telescope<CR>')
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
        hl = 'DarkTerminal',
        blend = 0,
        on_exit = function(job_id, _, _)
          for i, _ in ipairs(_G.Bzub.Terms) do
            if _G.Bzub.Terms[i].job_id_copy == job_id then
              table.remove(_G.Bzub.Terms, i)
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

      map('n', '][', '<CMD>lua _G.Bzub.ToggleTerm(vim.api.nvim_get_current_tabpage())<CR>')
      map('i', '][', '<CMD>lua _G.Bzub.ToggleTerm(vim.api.nvim_get_current_tabpage())<CR>')
      map('t', '][', '<C-\\><C-n><CMD>lua _G.Bzub.ToggleTerm(vim.api.nvim_get_current_tabpage())<CR>')

      map('n', '[]', '<CMD>lua _G.Bzub.NewTerm()<CR>')
      map('i', '[]', '<CMD>lua _G.Bzub.NewTerm()<CR>')
      map('t', '[]', '<C-\\><C-n><CMD>lua _G.Bzub.NewTerm()<CR>')

      map('n', ']\\', '<CMD>lua _G.Bzub.NextTerm()<CR>')
      map('i', ']\\', '<CMD>lua _G.Bzub.NextTerm()<CR>')
      map('t', ']\\', '<C-\\><C-n><CMD>lua _G.Bzub.NextTerm()<CR>')

      map('n', '[\\', '<CMD>lua _G.Bzub.PreviousTerm()<CR>')
      map('i', '[\\', '<CMD>lua _G.Bzub.PreviousTerm()<CR>')
      map('t', '[\\', '<C-\\><C-n><CMD>lua _G.Bzub.PreviousTerm()<CR>')
    end,
  }

  use { 'kevinhwang91/nvim-bqf', ft = 'qf' }
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
      require 'mini.bufremove'.setup()
      require 'mini.comment'.setup()
      require 'mini.cursorword'.setup()
      require 'mini.fuzzy'.setup()
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
      require 'mini.jump'.setup()
      require 'mini.jump2d'.setup()
      require 'mini.misc'.setup()
      require 'mini.pairs'.setup()
      require 'mini.statusline'.setup()
      require 'mini.surround'.setup()
      require 'mini.tabline'.setup({
        tabpage_section = 'right',
      })
      require 'mini.trailspace'.setup()
    end
  }

  use { 'ray-x/navigator.lua',
    requires = { 'ray-x/guihua.lua', run = 'cd lua/fzy && make' },
    config = function()
      require 'navigator'.setup({
        on_attach = function(client)
          vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        end,
        treesitter_analysis = true,
        lsp = {
          disable_lsp = {
            'terraform_lsp',
            'dockerls',
          },
          diagnostic = {
            virtual_text = false,
          },
          code_action = { enable = true, sign = true, sign_priority = 40, virtual_text = false },
          code_lens_action = { enable = true, sign = true, sign_priority = 40, virtual_text = false },
          yamlls = {
            settings = {
              yaml = {
                schemas = {
                  ["/Users/z003vkg/jsonschemas/kpt/all.json"] = "Kptfile",
                  ["/Users/z003vkg/jsonschemas/talos/config.json"] = "/*/machineconfig_*.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/daemonset.json"] = "daemonset.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/policyrule.json"] = "policyrule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/iscsivolumesource.json"] = "iscsivolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicationcontroller.json"] = "replicationcontroller.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumenodeaffinity.json"] = "volumenodeaffinity.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourcesubresourcestatus.json"] = "customresourcesubresourcestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointsubset.json"] = "endpointsubset.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/runtimeclasslist.json"] = "runtimeclasslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterresourceset.json"] = "clusterresourceset.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podsecuritycontext.json"] = "podsecuritycontext.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csistoragecapacitylist.json"] = "csistoragecapacitylist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/portworxvolumesource.json"] = "portworxvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/subjectrulesreviewstatus.json"] = "subjectrulesreviewstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/topologyspreadconstraint.json"] = "topologyspreadconstraint.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerimage.json"] = "containerimage.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statefulsetstatus.json"] = "statefulsetstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/daemonsetupdatestrategy.json"] = "daemonsetupdatestrategy.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metalmachine.json"] = "metalmachine.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flowschemastatus.json"] = "flowschemastatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourceattributes.json"] = "resourceattributes.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumemount.json"] = "volumemount.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/joblist.json"] = "joblist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ipblock.json"] = "ipblock.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/hostalias.json"] = "hostalias.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scale.json"] = "scale.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/emptydirvolumesource.json"] = "emptydirvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/servicebackendport.json"] = "servicebackendport.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/runasuserstrategyoptions.json"] = "runasuserstrategyoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/tokenreview.json"] = "tokenreview.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/envvar.json"] = "envvar.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/groupsubject.json"] = "groupsubject.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/horizontalpodautoscalerstatus.json"] = "horizontalpodautoscalerstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/azurediskvolumesource.json"] = "azurediskvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podcondition.json"] = "podcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/storageclass.json"] = "storageclass.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicasetstatus.json"] = "replicasetstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/glusterfspersistentvolumesource.json"] = "glusterfspersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockermachinepoollist.json"] = "dockermachinepoollist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/attachedvolume.json"] = "attachedvolume.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/objectreference.json"] = "objectreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/limitrangelist.json"] = "limitrangelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicationcontrollerspec.json"] = "replicationcontrollerspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/portstatus.json"] = "portstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/componentcondition.json"] = "componentcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volume.json"] = "volume.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/namespacelist.json"] = "namespacelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serviceaccountlist.json"] = "serviceaccountlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterissuerlist.json"] = "clusterissuerlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingresstls.json"] = "ingresstls.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/hpascalingpolicy.json"] = "hpascalingpolicy.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/idrange.json"] = "idrange.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/allowedflexvolume.json"] = "allowedflexvolume.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicationcontrollerstatus.json"] = "replicationcontrollerstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rbdvolumesource.json"] = "rbdvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serverclass.json"] = "serverclass.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/mutatingwebhook.json"] = "mutatingwebhook.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/localobjectreference.json"] = "localobjectreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csidriver.json"] = "csidriver.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ephemeralvolumesource.json"] = "ephemeralvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/secretenvsource.json"] = "secretenvsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourceconversion.json"] = "customresourceconversion.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/gitrepovolumesource.json"] = "gitrepovolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/quobytevolumesource.json"] = "quobytevolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podsecuritypolicylist.json"] = "podsecuritypolicylist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/kubeadmconfigtemplatelist.json"] = "kubeadmconfigtemplatelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/horizontalpodautoscalerlist.json"] = "horizontalpodautoscalerlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumenoderesources.json"] = "volumenoderesources.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockermachine.json"] = "dockermachine.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statuscause.json"] = "statuscause.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/hostpathvolumesource.json"] = "hostpathvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterresourcesetbindinglist.json"] = "clusterresourcesetbindinglist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/windowssecuritycontextoptions.json"] = "windowssecuritycontextoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/talosconfiglist.json"] = "talosconfiglist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourcecolumndefinition.json"] = "customresourcecolumndefinition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificatesigningrequestlist.json"] = "certificatesigningrequestlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machineset.json"] = "machineset.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerstatewaiting.json"] = "containerstatewaiting.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/eventsource.json"] = "eventsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/binding.json"] = "binding.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/subjectaccessreviewstatus.json"] = "subjectaccessreviewstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/managedfieldsentry.json"] = "managedfieldsentry.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/priorityclasslist.json"] = "priorityclasslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiversions.json"] = "apiversions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicasetlist.json"] = "replicasetlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointhints.json"] = "endpointhints.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podsmetricstatus.json"] = "podsmetricstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/namespacestatus.json"] = "namespacestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/fcvolumesource.json"] = "fcvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/selfsubjectrulesreview.json"] = "selfsubjectrulesreview.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcequotalist.json"] = "resourcequotalist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/objectmetricstatus.json"] = "objectmetricstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/weightedpodaffinityterm.json"] = "weightedpodaffinityterm.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumelist.json"] = "persistentvolumelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/server.json"] = "server.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/boundobjectreference.json"] = "boundobjectreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcemetricstatus.json"] = "resourcemetricstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podtemplatespec.json"] = "podtemplatespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/role.json"] = "role.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerresourcemetricstatus.json"] = "containerresourcemetricstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deployment.json"] = "deployment.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/queuingconfiguration.json"] = "queuingconfiguration.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterresourcesetbinding.json"] = "clusterresourcesetbinding.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/capabilities.json"] = "capabilities.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scalestatus.json"] = "scalestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/envvarsource.json"] = "envvarsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/prioritylevelconfigurationstatus.json"] = "prioritylevelconfigurationstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodeaddress.json"] = "nodeaddress.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingresslist.json"] = "ingresslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/limitedprioritylevelconfiguration.json"] = "limitedprioritylevelconfiguration.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/validatingwebhookconfiguration.json"] = "validatingwebhookconfiguration.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/storageclasslist.json"] = "storageclasslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rollingupdatedaemonset.json"] = "rollingupdatedaemonset.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/externalmetricstatus.json"] = "externalmetricstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinedeploymentlist.json"] = "machinedeploymentlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serviceaccountsubject.json"] = "serviceaccountsubject.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podsecuritypolicy.json"] = "podsecuritypolicy.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/mutatingwebhookconfigurationlist.json"] = "mutatingwebhookconfigurationlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/usersubject.json"] = "usersubject.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/configmapvolumesource.json"] = "configmapvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podstatus.json"] = "podstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/projectedvolumesource.json"] = "projectedvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterresourcesetlist.json"] = "clusterresourcesetlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiservicelist.json"] = "apiservicelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumeclaimtemplate.json"] = "persistentvolumeclaimtemplate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/allowedhostpath.json"] = "allowedhostpath.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deleteoptions.json"] = "deleteoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cronjob.json"] = "cronjob.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/azurefilepersistentvolumesource.json"] = "azurefilepersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metalmachinetemplatelist.json"] = "metalmachinetemplatelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scopedresourceselectorrequirement.json"] = "scopedresourceselectorrequirement.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockermachinetemplatelist.json"] = "dockermachinetemplatelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statefulsetlist.json"] = "statefulsetlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serviceport.json"] = "serviceport.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumeclaimlist.json"] = "persistentvolumeclaimlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/configmapnodeconfigsource.json"] = "configmapnodeconfigsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podspec.json"] = "podspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csinodelist.json"] = "csinodelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cinderpersistentvolumesource.json"] = "cinderpersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/daemonsetstatus.json"] = "daemonsetstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumeerror.json"] = "volumeerror.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/keytopath.json"] = "keytopath.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressstatus.json"] = "ingressstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metalcluster.json"] = "metalcluster.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/servicestatus.json"] = "servicestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/networkpolicylist.json"] = "networkpolicylist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodeconfigsource.json"] = "nodeconfigsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/condition.json"] = "condition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/runtimeclass.json"] = "runtimeclass.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/fsgroupstrategyoptions.json"] = "fsgroupstrategyoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rulewithoperations.json"] = "rulewithoperations.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/allowedcsidriver.json"] = "allowedcsidriver.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/azurefilevolumesource.json"] = "azurefilevolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/orderlist.json"] = "orderlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clientipconfig.json"] = "clientipconfig.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/listmeta.json"] = "listmeta.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nonresourceattributes.json"] = "nonresourceattributes.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/leaselist.json"] = "leaselist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/validatingwebhookconfigurationlist.json"] = "validatingwebhookconfigurationlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressclassspec.json"] = "ingressclassspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/secretreference.json"] = "secretreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerport.json"] = "containerport.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flowschemalist.json"] = "flowschemalist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/daemonsetspec.json"] = "daemonsetspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpoint.json"] = "endpoint.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/poddnsconfigoption.json"] = "poddnsconfigoption.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/intorstring.json"] = "intorstring.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/prioritylevelconfigurationspec.json"] = "prioritylevelconfigurationspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/networkpolicyport.json"] = "networkpolicyport.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deploymentspec.json"] = "deploymentspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterrole.json"] = "clusterrole.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/runtimeclassstrategyoptions.json"] = "runtimeclassstrategyoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ownerreference_v2.json"] = "ownerreference_v2.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cronjobspec.json"] = "cronjobspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/selinuxoptions.json"] = "selinuxoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicasetcondition.json"] = "replicasetcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/eventlist.json"] = "eventlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcerequirements.json"] = "resourcerequirements.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/prioritylevelconfiguration.json"] = "prioritylevelconfiguration.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/servicelist.json"] = "servicelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodeselectorterm.json"] = "nodeselectorterm.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/service.json"] = "service.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodedaemonendpoints.json"] = "nodedaemonendpoints.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/prioritylevelconfigurationreference.json"] = "prioritylevelconfigurationreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/lifecycle.json"] = "lifecycle.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourcedefinitioncondition.json"] = "customresourcedefinitioncondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressclass.json"] = "ingressclass.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/affinity.json"] = "affinity.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumeclaimstatus.json"] = "persistentvolumeclaimstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/taloscontrolplanelist.json"] = "taloscontrolplanelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/objectmeta.json"] = "objectmeta.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/roleref.json"] = "roleref.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumeattachmentstatus.json"] = "volumeattachmentstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicationcontrollercondition.json"] = "replicationcontrollercondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/microtime.json"] = "microtime.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metricstatus.json"] = "metricstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/httpingresspath.json"] = "httpingresspath.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockercluster.json"] = "dockercluster.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csipersistentvolumesource.json"] = "csipersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockermachinepool.json"] = "dockermachinepool.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/vspherevirtualdiskvolumesource.json"] = "vspherevirtualdiskvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumeattachmentlist.json"] = "volumeattachmentlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/poddisruptionbudgetspec.json"] = "poddisruptionbudgetspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcefieldselector.json"] = "resourcefieldselector.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/securitycontext.json"] = "securitycontext.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apigrouplist.json"] = "apigrouplist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumeclaimvolumesource.json"] = "persistentvolumeclaimvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/controllerrevisionlist.json"] = "controllerrevisionlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/userinfo.json"] = "userinfo.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingress.json"] = "ingress.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/priorityclass.json"] = "priorityclass.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/jobstatus.json"] = "jobstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/hpascalingrules.json"] = "hpascalingrules.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerstateterminated.json"] = "containerstateterminated.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rollingupdatedeployment.json"] = "rollingupdatedeployment.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/selinuxstrategyoptions.json"] = "selinuxstrategyoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csivolumesource.json"] = "csivolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolume.json"] = "persistentvolume.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/talosconfig.json"] = "talosconfig.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/challenge.json"] = "challenge.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flowschemacondition.json"] = "flowschemacondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/execaction.json"] = "execaction.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metalmachinetemplate.json"] = "metalmachinetemplate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/event.json"] = "event.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/taloscontrolplane.json"] = "taloscontrolplane.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/downwardapiprojection.json"] = "downwardapiprojection.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csinode.json"] = "csinode.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockermachinetemplate.json"] = "dockermachinetemplate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodelist.json"] = "nodelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockerclusterlist.json"] = "dockerclusterlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/tokenrequest.json"] = "tokenrequest.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/preferredschedulingterm.json"] = "preferredschedulingterm.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiresourcelist.json"] = "apiresourcelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/_definitions.json"] = "_definitions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/webhookconversion.json"] = "webhookconversion.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ownerreference.json"] = "ownerreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/httpgetaction.json"] = "httpgetaction.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/challengelist.json"] = "challengelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinehealthchecklist.json"] = "machinehealthchecklist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/dockermachinelist.json"] = "dockermachinelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/sessionaffinityconfig.json"] = "sessionaffinityconfig.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csidriverlist.json"] = "csidriverlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deploymentstatus.json"] = "deploymentstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flowschema.json"] = "flowschema.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicaset.json"] = "replicaset.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/mutatingwebhookconfiguration.json"] = "mutatingwebhookconfiguration.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificatelist.json"] = "certificatelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podantiaffinity.json"] = "podantiaffinity.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scheduling.json"] = "scheduling.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/container.json"] = "container.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressspec.json"] = "ingressspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterrolelist.json"] = "clusterrolelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serviceaccount.json"] = "serviceaccount.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metricvaluestatus.json"] = "metricvaluestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/horizontalpodautoscalercondition.json"] = "horizontalpodautoscalercondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressrule.json"] = "ingressrule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scopeselector.json"] = "scopeselector.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/crossversionobjectreference.json"] = "crossversionobjectreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerstaterunning.json"] = "containerstaterunning.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcequotaspec.json"] = "resourcequotaspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rolebindinglist.json"] = "rolebindinglist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cephfspersistentvolumesource.json"] = "cephfspersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificatesigningrequest.json"] = "certificatesigningrequest.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podtemplatelist.json"] = "podtemplatelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deleteoptions_v2.json"] = "deleteoptions_v2.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/watchevent.json"] = "watchevent.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/subjectaccessreview.json"] = "subjectaccessreview.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumespec.json"] = "persistentvolumespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodeaffinity.json"] = "nodeaffinity.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiservice.json"] = "apiservice.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podsecuritypolicyspec.json"] = "podsecuritypolicyspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/configmap.json"] = "configmap.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/horizontalpodautoscalerspec.json"] = "horizontalpodautoscalerspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodeselectorrequirement.json"] = "nodeselectorrequirement.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/loadbalancerstatus.json"] = "loadbalancerstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/runasgroupstrategyoptions.json"] = "runasgroupstrategyoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificate.json"] = "certificate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/selfsubjectaccessreview.json"] = "selfsubjectaccessreview.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/prioritylevelconfigurationcondition.json"] = "prioritylevelconfigurationcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rollingupdatestatefulsetstrategy.json"] = "rollingupdatestatefulsetstrategy.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/configmapenvsource.json"] = "configmapenvsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/iscsipersistentvolumesource.json"] = "iscsipersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/jobtemplatespec.json"] = "jobtemplatespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicasetspec.json"] = "replicasetspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/time.json"] = "time.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metricspec.json"] = "metricspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metricidentifier.json"] = "metricidentifier.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/tokenreviewspec.json"] = "tokenreviewspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/configmapkeyselector.json"] = "configmapkeyselector.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourcedefinitionnames.json"] = "customresourcedefinitionnames.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificatesigningrequestspec.json"] = "certificatesigningrequestspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodeconfigstatus.json"] = "nodeconfigstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rawextension.json"] = "rawextension.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/networkpolicyingressrule.json"] = "networkpolicyingressrule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/quantity.json"] = "quantity.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiservicestatus.json"] = "apiservicestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/storageospersistentvolumesource.json"] = "storageospersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/labelselector.json"] = "labelselector.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/overhead.json"] = "overhead.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podaffinity.json"] = "podaffinity.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/limitresponse.json"] = "limitresponse.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cluster.json"] = "cluster.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/externaldocumentation.json"] = "externaldocumentation.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/horizontalpodautoscalerbehavior.json"] = "horizontalpodautoscalerbehavior.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/glusterfsvolumesource.json"] = "glusterfsvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podaffinityterm.json"] = "podaffinityterm.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/daemonsetcondition.json"] = "daemonsetcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/namespacespec.json"] = "namespacespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificaterequest.json"] = "certificaterequest.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/lease.json"] = "lease.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/issuerlist.json"] = "issuerlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointconditions.json"] = "endpointconditions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/probe.json"] = "probe.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/policyruleswithsubjects.json"] = "policyruleswithsubjects.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flockervolumesource.json"] = "flockervolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/poddisruptionbudgetstatus.json"] = "poddisruptionbudgetstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/limitrangespec.json"] = "limitrangespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/replicationcontrollerlist.json"] = "replicationcontrollerlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/seccompprofile.json"] = "seccompprofile.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/hostportrange.json"] = "hostportrange.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serverclasslist.json"] = "serverclasslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressbackend.json"] = "ingressbackend.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nonresourcepolicyrule.json"] = "nonresourcepolicyrule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/networkpolicypeer.json"] = "networkpolicypeer.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metrictarget.json"] = "metrictarget.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodeselector.json"] = "nodeselector.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/issuer.json"] = "issuer.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/topologyselectorlabelrequirement.json"] = "topologyselectorlabelrequirement.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/servicereference.json"] = "servicereference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/secretprojection.json"] = "secretprojection.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/configmapprojection.json"] = "configmapprojection.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/job.json"] = "job.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodesysteminfo.json"] = "nodesysteminfo.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcerule.json"] = "resourcerule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/validatingwebhook.json"] = "validatingwebhook.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointaddress.json"] = "endpointaddress.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/poddisruptionbudget.json"] = "poddisruptionbudget.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serverbindinglist.json"] = "serverbindinglist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/labelselectorrequirement.json"] = "labelselectorrequirement.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/limitrangeitem.json"] = "limitrangeitem.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flexpersistentvolumesource.json"] = "flexpersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/namespacecondition.json"] = "namespacecondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/toleration.json"] = "toleration.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/kubeadmconfigtemplate.json"] = "kubeadmconfigtemplate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metalmachinelist.json"] = "metalmachinelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumeattachmentsource.json"] = "volumeattachmentsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nfsvolumesource.json"] = "nfsvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterissuer.json"] = "clusterissuer.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/sysctl.json"] = "sysctl.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/metalclusterlist.json"] = "metalclusterlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointport.json"] = "endpointport.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/tokenrequestspec.json"] = "tokenrequestspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/jobspec.json"] = "jobspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cephfsvolumesource.json"] = "cephfsvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/httpingressrulevalue.json"] = "httpingressrulevalue.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/namespace.json"] = "namespace.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cronjobstatus.json"] = "cronjobstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/kubeadmconfiglist.json"] = "kubeadmconfiglist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumestatus.json"] = "persistentvolumestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/json.json"] = "json.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/horizontalpodautoscaler.json"] = "horizontalpodautoscaler.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/info.json"] = "info.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/talosconfigtemplatelist.json"] = "talosconfigtemplatelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/httpheader.json"] = "httpheader.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scaleiopersistentvolumesource.json"] = "scaleiopersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/downwardapivolumefile.json"] = "downwardapivolumefile.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apigroup.json"] = "apigroup.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/tokenreviewstatus.json"] = "tokenreviewstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/secretvolumesource.json"] = "secretvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/poddnsconfig.json"] = "poddnsconfig.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerstate.json"] = "containerstate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/supplementalgroupsstrategyoptions.json"] = "supplementalgroupsstrategyoptions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/pod.json"] = "pod.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serviceaccounttokenprojection.json"] = "serviceaccounttokenprojection.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/provider.json"] = "provider.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinepool.json"] = "machinepool.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodespec.json"] = "nodespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scalespec.json"] = "scalespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podtemplate.json"] = "podtemplate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csidriverspec.json"] = "csidriverspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podip.json"] = "podip.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourcesubresourcescale.json"] = "customresourcesubresourcescale.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serverbinding.json"] = "serverbinding.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/handler.json"] = "handler.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinesetlist.json"] = "machinesetlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificaterequestlist.json"] = "certificaterequestlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiservicecondition.json"] = "apiservicecondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/topologyselectorterm.json"] = "topologyselectorterm.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csistoragecapacity.json"] = "csistoragecapacity.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/secret.json"] = "secret.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/kubeadmconfig.json"] = "kubeadmconfig.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rbdpersistentvolumesource.json"] = "rbdpersistentvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/secretlist.json"] = "secretlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/groupversionfordiscovery.json"] = "groupversionfordiscovery.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/typedlocalobjectreference.json"] = "typedlocalobjectreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointslicelist.json"] = "endpointslicelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/subject.json"] = "subject.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/webhookclientconfig.json"] = "webhookclientconfig.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcequotastatus.json"] = "resourcequotastatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinehealthcheck.json"] = "machinehealthcheck.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumeprojection.json"] = "volumeprojection.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/componentstatuslist.json"] = "componentstatuslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressservicebackend.json"] = "ingressservicebackend.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/limitrange.json"] = "limitrange.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serverlist.json"] = "serverlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumedevice.json"] = "volumedevice.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machine.json"] = "machine.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nonresourcerule.json"] = "nonresourcerule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/objectfieldselector.json"] = "objectfieldselector.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodecondition.json"] = "nodecondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/kubeadmcontrolplane.json"] = "kubeadmcontrolplane.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/patch.json"] = "patch.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/networkpolicy.json"] = "networkpolicy.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiresource.json"] = "apiresource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/serveraddressbyclientcidr.json"] = "serveraddressbyclientcidr.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcequota.json"] = "resourcequota.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/jobcondition.json"] = "jobcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flexvolumesource.json"] = "flexvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterrolebindinglist.json"] = "clusterrolebindinglist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/status_v2.json"] = "status_v2.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumeattachment.json"] = "volumeattachment.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinelist.json"] = "machinelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/tokenrequeststatus.json"] = "tokenrequeststatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/tcpsocketaction.json"] = "tcpsocketaction.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statefulsetcondition.json"] = "statefulsetcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/storageosvolumesource.json"] = "storageosvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statusdetails_v2.json"] = "statusdetails_v2.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/nodestatus.json"] = "nodestatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterlist.json"] = "clusterlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/volumeattachmentspec.json"] = "volumeattachmentspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/poddisruptionbudgetlist.json"] = "poddisruptionbudgetlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deploymentstrategy.json"] = "deploymentstrategy.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/aggregationrule.json"] = "aggregationrule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statefulsetupdatestrategy.json"] = "statefulsetupdatestrategy.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/daemonendpoint.json"] = "daemonendpoint.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumeclaim.json"] = "persistentvolumeclaim.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/eventseries.json"] = "eventseries.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/providerlist.json"] = "providerlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/node.json"] = "node.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/objectmetricsource.json"] = "objectmetricsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/servicespec.json"] = "servicespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deploymentlist.json"] = "deploymentlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/networkpolicyegressrule.json"] = "networkpolicyegressrule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cronjoblist.json"] = "cronjoblist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointslist.json"] = "endpointslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podsmetricsource.json"] = "podsmetricsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/status.json"] = "status.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/localvolumesource.json"] = "localvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flowdistinguishermethod.json"] = "flowdistinguishermethod.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statusdetails.json"] = "statusdetails.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ephemeralcontainer.json"] = "ephemeralcontainer.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerresourcemetricsource.json"] = "containerresourcemetricsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcemetricsource.json"] = "resourcemetricsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/environment.json"] = "environment.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinepoollist.json"] = "machinepoollist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourcesubresources.json"] = "customresourcesubresources.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/selfsubjectaccessreviewspec.json"] = "selfsubjectaccessreviewspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificatesigningrequestcondition.json"] = "certificatesigningrequestcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/kubeadmcontrolplanelist.json"] = "kubeadmcontrolplanelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressclasslist.json"] = "ingressclasslist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/flowschemaspec.json"] = "flowschemaspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/daemonsetlist.json"] = "daemonsetlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/fieldsv1.json"] = "fieldsv1.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/containerstatus.json"] = "containerstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/environmentlist.json"] = "environmentlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/subjectaccessreviewspec.json"] = "subjectaccessreviewspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/eviction.json"] = "eviction.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scaleiovolumesource.json"] = "scaleiovolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/loadbalanceringress.json"] = "loadbalanceringress.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/leasespec.json"] = "leasespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/componentstatus.json"] = "componentstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/prioritylevelconfigurationlist.json"] = "prioritylevelconfigurationlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/order.json"] = "order.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/taint.json"] = "taint.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumeclaimcondition.json"] = "persistentvolumeclaimcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/photonpersistentdiskvolumesource.json"] = "photonpersistentdiskvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/configmaplist.json"] = "configmaplist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/externalmetricsource.json"] = "externalmetricsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/secretkeyselector.json"] = "secretkeyselector.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/gcepersistentdiskvolumesource.json"] = "gcepersistentdiskvolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statefulset.json"] = "statefulset.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/cindervolumesource.json"] = "cindervolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/networkpolicyspec.json"] = "networkpolicyspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podlist.json"] = "podlist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csinodespec.json"] = "csinodespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/talosconfigtemplate.json"] = "talosconfigtemplate.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rolebinding.json"] = "rolebinding.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/machinedeployment.json"] = "machinedeployment.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/ingressclassparametersreference.json"] = "ingressclassparametersreference.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/envfromsource.json"] = "envfromsource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/downwardapivolumesource.json"] = "downwardapivolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/clusterrolebinding.json"] = "clusterrolebinding.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/customresourcedefinitionstatus.json"] = "customresourcedefinitionstatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/selfsubjectrulesreviewspec.json"] = "selfsubjectrulesreviewspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/csinodedriver.json"] = "csinodedriver.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/all.json"] = "all.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/objectmeta_v2.json"] = "objectmeta_v2.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/awselasticblockstorevolumesource.json"] = "awselasticblockstorevolumesource.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/rolelist.json"] = "rolelist.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/deploymentcondition.json"] = "deploymentcondition.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpoints.json"] = "endpoints.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/apiservicespec.json"] = "apiservicespec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/statefulsetspec.json"] = "statefulsetspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/resourcepolicyrule.json"] = "resourcepolicyrule.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/localsubjectaccessreview.json"] = "localsubjectaccessreview.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/persistentvolumeclaimspec.json"] = "persistentvolumeclaimspec.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/forzone.json"] = "forzone.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/preconditions.json"] = "preconditions.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/scale_v2.json"] = "scale_v2.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/endpointslice.json"] = "endpointslice.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/certificatesigningrequeststatus.json"] = "certificatesigningrequeststatus.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/controllerrevision.json"] = "controllerrevision.yaml",
                  ["/Users/z003vkg/jsonschemas/kubernetes/podreadinessgate.json"] = "podreadinessgate.yaml",
                },
              },
            },
          },
        },
      })
    end
  }
end,
config = {
  display = {
    open_fn = require('packer.util').float,
  },
},
})