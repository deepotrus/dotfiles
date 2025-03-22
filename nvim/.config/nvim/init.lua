-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.cmd("inoremap jk <Esc>")
vim.cmd("inoremap kj <Esc>")
vim.cmd("LushwalCompile")
require("transparent").clear_prefix("NeoTree")
require("transparent").clear_prefix("lualine")
