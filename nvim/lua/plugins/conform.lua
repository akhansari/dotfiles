return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["javascript"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["json"] = { "prettier" },
      },
      -- formatters = {
      --   biome = {
      --     condition = function(ctx)
      --       return vim.fs.find({ "biome.json" }, { path = ctx.filename, upward = true })[1]
      --     end,
      --   },
      --   prettier = {
      --     condition = function(ctx)
      --       return not vim.fs.find({ "biome.json" }, { path = ctx.filename, upward = true })[1]
      --     end,
      --   },
      -- },
    },
  },
}
