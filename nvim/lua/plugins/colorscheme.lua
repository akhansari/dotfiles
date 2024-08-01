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
    "rebelot/kanagawa.nvim",
    opts = {
      transparent = true,
    },
  },

  { "Shatur/neovim-ayu" },

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
      colorscheme = "catppuccin",
    },
  },
}
