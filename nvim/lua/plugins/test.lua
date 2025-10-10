return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      -- "nvim-neotest/neotest-jest",
      -- "Issafalcon/neotest-dotnet",
    },
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
