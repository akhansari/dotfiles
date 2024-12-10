local nvim_lsp = require("lspconfig")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
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
}
