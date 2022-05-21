HOME = os.getenv("HOME")

-- basic settings
vim.o.encoding = "utf-8"
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.o.history = 1000
vim.o.scrollback = 1000

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
vim.o.background = 'dark'
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
