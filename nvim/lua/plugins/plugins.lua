return {

  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        biome = {
          require_cwd = false,
        },
      },
    },
  },

  -- {
  --   "dmmulroy/ts-error-translator.nvim",
  --   opts = {
  --     auto_attach = true,
  --     servers = {
  --       "svelte",
  --       "vtsls",
  --     },
  --   },
  -- },

  -- {
  --   "Jezda1337/nvim-html-css",
  --   dependencies = { "hrsh7th/nvim-cmp", "nvim-treesitter/nvim-treesitter" },
  -- },
}
