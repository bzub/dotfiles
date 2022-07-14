-- vim.api.
vim.cmd([[
  function! s:gruvbox_material_custom() abort
    filetype indent off
    set termguicolors
    set background=dark
    let g:gruvbox_material_better_performance = 0
    let g:gruvbox_material_background = 'medium'
    let g:gruvbox_material_enable_italic = 1
    let g:gruvbox_material_enable_bold = 1
    let g:gruvbox_material_ui_contrast = 'high'
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
