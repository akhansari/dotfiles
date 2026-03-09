return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        virtual_text = false, -- for tiny-inline-diagnostic
      },
      inlay_hints = {
        enabled = false,
      },
      servers = {

        vtsls = {
          enabled = false,
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
        tsgo = {},

        jsonls = {
          settings = {
            json = {
              format = {
                enable = false,
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
      require("tiny-inline-diagnostic").setup({
        options = {
          add_messages = {
            display_count = true,
          },
          multilines = {
            enabled = true,
          },
        },
      })
    end,
  },
}
