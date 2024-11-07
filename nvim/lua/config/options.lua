-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.o.shell = "nu"
vim.o.shellcmdflag = "-c"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

vim.o.tabstop = 4
vim.o.shiftwidth = 4

vim.o.title = true
vim.o.titlestring = '%(%{expand("%:~:.:h")}%)/%t %m'

vim.o.backupcopy = "yes" -- make file watcher work on save
