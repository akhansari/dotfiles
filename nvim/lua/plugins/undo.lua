return {
  {
    "y3owk1n/time-machine.nvim",
    opts = {
      diff_tool = "delta",
      keymaps = {
        undo = "e",
        redo = "u",
        restore_undopoint = "o",
        preview_sequence_diff = "<CR>",
      },
    },
    keys = {
      {
        "<leader>U",
        "<cmd>TimeMachineToggle<cr>",
        desc = "[Time Machine] Toggle Tree",
      },
    },
  },
}
