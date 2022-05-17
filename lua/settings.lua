HOME = os.getenv("HOME")

-- basic settings
vim.o.encoding = "utf-8"
-- vim.o.backspace = "indent,eol,start" -- backspace works on every char in insert mode
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.o.history = 1000
vim.o.scrollback = 1000
-- vim.o.dictionary = '/usr/share/dict/words'
-- vim.o.startofline = true

-- Only show cursorline in the current window and in normal mode.
vim.cmd([[
  augroup cline
      au!
      au WinLeave * set nocursorline
      au WinEnter * set cursorline
      au InsertEnter * set nocursorline
      au InsertLeave * set cursorline
      au WinLeave * set nocursorcolumn
      au WinEnter * set cursorcolumn
      au InsertEnter * set nocursorcolumn
      au InsertLeave * set cursorcolumn
  augroup END
]])

-- Hide Info(Preview) window after completions.
vim.cmd([[
  autocmd InsertLeave * if pumvisible() == 0|pclose|endif
]])

vim.o.wrap = false
vim.o.termguicolors = true
if (os.getenv('EDITOR_BACKGROUND') ~= nil) then
  vim.o.background = os.getenv('EDITOR_BACKGROUND')
else
  vim.o.background = 'dark'
end
if (os.getenv('EDITOR_CONTRAST') ~= nil) then
  vim.g.gruvbox_material_background = os.getenv('EDITOR_CONTRAST')
else
  vim.g.gruvbox_material_background = 'hard'
end
vim.cmd('colorscheme gruvbox-material')
vim.o.hidden = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 8

-- Kptfile
vim.cmd([[ autocmd BufNewFile,BufRead Kptfile set syntax=yaml ]])
vim.cmd([[ autocmd BufNewFile,BufRead Kptfile set ft=yaml ]])

-- Sessions
local sessionoptions = {
  "blank",
  "buffers",
  "curdir",
  "folds",
  "help",
  "tabpages",
  "winsize",
  -- "globals",
  "options",
  "localoptions",
  "resize",
  "terminal",
  "winpos",
}
vim.o.sessionoptions = table.concat(sessionoptions, ",")
