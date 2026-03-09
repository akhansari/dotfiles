return {
  {
    "nvim-mini/mini.indentscope",
    opts = {
      symbol = "",
      draw = {
        animation = require("mini.indentscope").gen_animation.none(),
      },
      mappings = {
        -- object_scope = "fallback",
      },
    },
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.config
    opts = {
      indent = { enabled = false },
    },
  },

  {
    "nvim-mini/mini.files",
    opts = {
      windows = {
        preview = true,
        width_preview = 80,
      },
      options = {
        use_as_default_explorer = true,
      },
      mappings = {
        go_in = "e",
        go_in_plus = "E",
        go_out = "u",
        go_out_plus = "U",
      },
    },
  },
}
