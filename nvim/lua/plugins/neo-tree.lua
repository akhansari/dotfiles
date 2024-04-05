return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          ["p"] = "noop",
          ["i"] = "noop",
          ["é"] = "show_file_details",
          ["v"] = "paste_from_clipboard",
        },
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
      },
    },
  },
}
