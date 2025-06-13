local nvim_lsp = require("lspconfig")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      inlay_hints = {
        enabled = false,
      },
      codelens = {
        enabled = false,
      },
      servers = {
        denols = {
          root_dir = nvim_lsp.util.root_pattern("deno.json"),
        },
        vtsls = {
          root_dir = nvim_lsp.util.root_pattern("package.json"),
        },
      },
    },
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy", -- Or `LspAttach`
    priority = 1000, -- Needs to be loaded in first
    config = function()
      require("tiny-inline-diagnostic").setup()
    end,
  },
}
