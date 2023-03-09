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
vim.o.wildmode = "longest:full,full,lastused:full"

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

-- Functions
local cleanup_buffers = function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(buf) == "" and vim.api.nvim_buf_get_offset(buf, 0) == -1
    then
      vim.api.nvim_buf_delete(buf, {})
    end
  end
end

local clear_matches = function()
  vim.cmd([[noh]])
  vim.fn.clearmatches()
end

-- Mappings
local opts = { noremap = true, silent = false }
vim.keymap.set("n", '<C-B>', function()
  cleanup_buffers()
  clear_matches()
end, opts)

local keys = {
  [[<C-CR>]],
  [[<M-CR>]],
  -- [[<C-space>]],
  -- [[<M-Space>]],
  [[<C-Tab>]],
  [[<M-Tab>]],
}

local msg_fn = function(msg)
  return function()
    vim.notify(msg)
  end
end

for _, key in pairs(keys) do
  local notify = function()
    local msg='YOU PRESSED: ' .. key
    vim.notify(msg)
  end
  vim.keymap.set("n", key, notify, opts)
end

vim.keymap.set("n", [[�0]], msg_fn("YOU PRESSED: CustomKey #0"), opts)
vim.keymap.set("n", [[�1]], msg_fn("YOU PRESSED: CustomKey #1"), opts)
vim.keymap.set("n", [[�2]], msg_fn("YOU PRESSED: CustomKey #2"), opts)
vim.keymap.set("n", [[�3]], msg_fn("YOU PRESSED: CustomKey #3"), opts)
vim.keymap.set("n", [[�4]], msg_fn("YOU PRESSED: CustomKey #4"), opts)
vim.keymap.set("n", [[�5]], msg_fn("YOU PRESSED: CustomKey #5"), opts)
vim.keymap.set("n", [[�6]], msg_fn("YOU PRESSED: CustomKey #6"), opts)
vim.keymap.set("n", [[�7]], msg_fn("YOU PRESSED: CustomKey #7"), opts)
vim.keymap.set("n", [[�8]], msg_fn("YOU PRESSED: CustomKey #8"), opts)
vim.keymap.set("n", [[�9]], msg_fn("YOU PRESSED: CustomKey #9"), opts)


-- Exit terminal
vim.keymap.set("t", [[�d]], [[]], opts)

-- Toggles terminal
local toggleterm = require'toggleterm'
local toggle_with_direction = function(direction)
  return function()
    toggleterm.toggle(vim.v.count, nil, nil, direction)
  end
end
vim.keymap.set({ "n", "t" }, [[�ñ]], toggle_with_direction(nil), opts) -- F1
vim.keymap.set({ "n", "t" }, [[�ò]], toggle_with_direction("float"), opts) -- F2
vim.keymap.set("n", [[�ó]], msg_fn("YOU PRESSED: CustomKey #F3"), opts)
vim.keymap.set("n", [[�ô]], msg_fn("YOU PRESSED: CustomKey #F4"), opts)
vim.keymap.set("n", [[�õ]], msg_fn("YOU PRESSED: CustomKey #F5"), opts)
vim.keymap.set("n", [[�ö]], msg_fn("YOU PRESSED: CustomKey #F6"), opts)
vim.keymap.set("n", [[�÷]], msg_fn("YOU PRESSED: CustomKey #F7"), opts)
vim.keymap.set("n", [[�ø]], msg_fn("YOU PRESSED: CustomKey #F8"), opts)
vim.keymap.set("n", [[�ù]], msg_fn("YOU PRESSED: CustomKey #F9"), opts)
vim.keymap.set("n", [[�༐]], msg_fn("YOU PRESSED: CustomKey #F10"), opts)
vim.keymap.set("n", [[�༑]], msg_fn("YOU PRESSED: CustomKey #F11"), opts)
vim.keymap.set("n", [[�༒]], msg_fn("YOU PRESSED: CustomKey #F12"), opts)
