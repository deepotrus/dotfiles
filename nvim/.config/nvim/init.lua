-- Keymaps
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "kj", "<Esc>")

-- Options
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.clipboard      = "unnamedplus"
vim.opt.termguicolors  = true   -- needed for true hex colors from wal

-- Load wal colorscheme
require("wal").load()