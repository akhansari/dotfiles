return {

  {
    "folke/tokyonight.nvim",
    lazy = true,
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
}
