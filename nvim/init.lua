-- bootstrap lazy.nvim, LazyVim and your plugins
vim.api.nvim_exec("language en_US", true)
require("config.lazy")
require("lspconfig").tsp_server.setup({})
