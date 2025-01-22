return {

  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
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
      lualine = {
        transparent = true,
      },
    },
  },

  {
    "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
    },
  },

  {
    "Shatur/neovim-ayu",
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu",
    },
  },
}
