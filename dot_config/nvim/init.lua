-- vim.api.
vim.cmd([[
  function! s:gruvbox_material_custom() abort
    filetype indent on
    set termguicolors
    set background=dark
    let g:gruvbox_material_better_performance = 1
    let g:gruvbox_material_background = 'medium'
    let g:gruvbox_material_enable_italic = 1
    let g:gruvbox_material_enable_bold = 1
    let g:gruvbox_material_ui_contrast = 'high'
    let l:hard_palette = gruvbox_material#get_palette('hard', 'material', {})
    let l:medium_palette = gruvbox_material#get_palette('medium', 'material', {})

    " mini.nvim
    call gruvbox_material#highlight('NormalHard', l:hard_palette.fg0, l:hard_palette.bg0)
    call gruvbox_material#highlight('MiniCursorword', l:medium_palette.none, l:medium_palette.none, 'underline')
    highlight MiniJump2dSpot gui=bold,nocombine guifg=white guibg=black

    " Neogit
    hi NeogitNotificationInfo guifg=#80ff95
    hi NeogitNotificationWarning guifg=#fff454
    hi NeogitNotificationError guifg=#c44323
    hi NeogitDiffAddHighlight guibg=#404040 guifg=#859900
    hi NeogitDiffDeleteHighlight guibg=#404040 guifg=#dc322f
    hi NeogitDiffContextHighlight guibg=#333333 guifg=#b2b2b2
    hi NeogitHunkHeader guifg=#cccccc guibg=#404040
    hi NeogitHunkHeaderHighlight guifg=#cccccc guibg=#4d4d4d
  endfunction

  augroup GruvboxMaterialCustom
    autocmd!
    autocmd ColorScheme gruvbox-material call s:gruvbox_material_custom()
  augroup END
]])
require('settings')
require('mappings')
require('plugins')
vim.cmd([[colorscheme gruvbox-material]])
vim.cmd([[colorscheme gruvbox-material]])
