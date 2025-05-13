return {

  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      -- on_colors = function(colors)
      --   colors.border = colors.blue7
      -- end,
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
    config = function()
      require("ayu").setup({
        overrides = {
          SnacksPickerGitStatusUntracked = { fg = "#565B66" },
          SnacksPickerDir = { fg = "#565B66" },
        },
      })
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ayu",
    },
  },
}
