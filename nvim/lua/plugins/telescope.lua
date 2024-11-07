return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    opts = {
      defaults = {
        initial_mode = "normal",
        mappings = {
          n = {
            ["p"] = "move_selection_previous",
            ["i"] = "move_selection_next",
          },
        },
      },
    },
    config = function(_, opts)
      local ts = require("telescope")
      ts.setup(opts)
      ts.load_extension("live_grep_args")
    end,
  },
}
