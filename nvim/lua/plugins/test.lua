return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "Issafalcon/neotest-dotnet",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {},
        ["neotest-vitest"] = {},
        ["neotest-dotnet"] = {},
      },
    },
  },
  {
    "andythigpen/nvim-coverage",
    -- version = "*",
    -- config = function()
    --   require("coverage").setup({
    --     auto_reload = true,
    --   })
    -- end,
  },
}
