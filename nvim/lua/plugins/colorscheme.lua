return {

  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      on_colors = function(colors)
        colors.border = colors.blue7
      end,
    },
  },

  {
    "navarasu/onedark.nvim",
    opts = {
      style = "darker",
      transparent = true,
    },
  },

  {
    "catppuccin/nvim",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      dim_inactive = { enabled = true, percentage = 0.01 },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
