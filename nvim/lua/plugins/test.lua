return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      -- "nvim-neotest/neotest-jest",
      -- "Issafalcon/neotest-dotnet",
    },
    ---@type neotest.Config
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
        -- ["neotest-jest"] = {},
        -- ["neotest-dotnet"] = {},
      },
    },
  },

  {
    "andythigpen/nvim-coverage",
    version = "*",
    config = function()
      require("coverage").setup({
        auto_reload = true,
      })
    end,
  },
}
