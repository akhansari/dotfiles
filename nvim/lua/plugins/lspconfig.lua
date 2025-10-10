-- local nvim_lsp = require("lspconfig")

return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      diagnostics = {
        virtual_text = false,
      },
      inlay_hints = {
        enabled = false,
      },
      codelens = {
        enabled = true,
      },
      servers = {
        vtsls = {
          settings = {
            typescript = {
              tsserver = {
                experimental = {
                  enableProjectDiagnostics = true,
                },
              },
            },
          },
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
