HOME = os.getenv("HOME")

-- Global statusline
vim.o.laststatus = 3

-- basic settings
vim.o.encoding = "utf-8"
vim.o.completeopt = 'menuone,noinsert,noselect'
vim.o.history = 1000
vim.o.scrollback = 1000
vim.o.foldlevelstart = 999
vim.o.verbose = false
vim.o.relativenumber = true
vim.o.number = true
vim.o.mouse = ""
vim.o.cmdheight = 0
vim.o.wildmode = "longest,list,full"

-- vim.o.writebackup = true --  protect against crash-during-write
-- vim.o.nobackup = true --  but do not persist backup after successful write
-- vim.o.backupcopy = 'auto' --  use rename-and-write-new method whenever safe

-- Use `git grep` for :grep
-- Maybe this instea? https://gist.github.com/hotchpotch/719707
vim.o.grepprg = 'git --no-pager grep --no-color -n $*'
vim.o.grepformat = '%f:%l:%m,%m %f match%ts,%f'

--  persist the undo tree for each file
vim.o.undofile = true

-- ShaDa
-- shada=!,'100,<50,s10,h
vim.o.shada = [[!,'1000,f1,<1000,h,%]]

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

vim.cmd([[
  augroup neovim_terminal
    autocmd!
    " Disables number lines on terminal buffers
    " autocmd TermOpen * :set nonumber norelativenumber
    " Allows you to use Ctrl-c on terminal window
    " autocmd TermOpen * nnoremap <buffer> <C-c> i<C-c>
    " No indentscope
    autocmd TermOpen * :let b:miniindentscope_disable=v:true
  augroup END
]])

-- Hide Info(Preview) window after completions.
vim.cmd([[
  autocmd InsertLeave * if pumvisible() == 0|pclose|endif
]])

vim.o.wrap = false
vim.o.hidden = true
vim.o.incsearch = true
vim.o.hlsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 8

-- Kptfile
-- vim.cmd([[ autocmd BufNewFile,BufRead Kptfile set syntax=yaml ]])
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
