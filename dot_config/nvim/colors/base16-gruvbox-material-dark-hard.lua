local use_cterm, palette

local base16 = require('mini.base16')
-- if vim.o.background == 'dark' then
palette = {
  base00 = '#202020', -- bg
  base01 = '#2a2827', -- bg2
  base02 = '#504945', -- bg6
  base03 = '#5a524c', -- bg8
  base04 = '#bdae93', -- p-fg3
  base05 = '#ddc7a1', -- fg
  base06 = '#ebdbb2', -- p-fg1
  base07 = '#fbf1c7', -- p-fg0
  base08 = '#ea6962', -- red
  base09 = '#e78a4e', -- orange
  base0A = '#d8a657', -- yellow
  base0B = '#a9b665', -- green
  base0C = '#89b482', -- aqua/cyan
  base0D = '#7daea3', -- blue
  base0E = '#d3869b', -- purple
  base0F = '#bd6f3e', -- dim-orange
}
use_cterm = base16.rgb_palette_to_cterm_palette(palette)
-- end

if palette then
  base16.setup({ palette = palette, use_cterm = use_cterm })
  vim.g.colors_name = 'base16-gruvbox-material-dark-hard'
end
