return {
  {
    "nvim-telescope/telescope.nvim",
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
  },
}
