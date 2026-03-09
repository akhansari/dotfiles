return {

  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
    },
  },

  -- {
  --   "ThePrimeagen/99",
  --   config = function()
  --     -- workaround to override the OpenCode permissions
  --     vim.fn.setenv("OPENCODE_PERMISSION", '{"edit": "allow"}')
  --
  --     local _99 = require("99")
  --
  --     _99.setup({
  --       model = "github-copilot/claude-sonnet-4.6",
  --       provider = _99.OpenCodeProvider,
  --       md_files = {
  --         "AGENTS.md",
  --       },
  --     })
  --
  --     vim.keymap.set("v", "<leader>anp", function()
  --       _99.visual()
  --     end, { desc = "99 visual selection with prompt" })
  --
  --     vim.keymap.set("n", "<leader>ans", function()
  --       _99.stop_all_requests()
  --     end, { desc = "99 stop all requests" })
  --
  --     vim.keymap.set("n", "<leader>anf", function()
  --       _99.search()
  --     end, { desc = "99 search" })
  --   end,
  -- },

  -- {
  --   "olimorris/codecompanion.nvim",
  --   opts = {},
  -- },
}
