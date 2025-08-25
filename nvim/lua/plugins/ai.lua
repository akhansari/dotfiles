return {
  -- {
  --   "zbirenbaum/copilot.lua",
  --   event = "InsertEnter",
  --   opts = {
  --     suggestion = {
  --       auto_trigger = true,
  --       keymap = {
  --         accept = "<C-a>",
  --         accept_line = "<C-l>",
  --         next = "<C-n>",
  --         dismiss = "<C-d>",
  --       },
  --     },
  --     panel = { enabled = false },
  --   },
  -- },

  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = {
            name = "copilot",
            model = "gpt-5",
          },
        },
      },
    },
  },
}
