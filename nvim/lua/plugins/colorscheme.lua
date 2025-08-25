return {

  { "bluz71/vim-moonfly-colors", name = "moonfly" },

  -- {
  --   "NLKNguyen/papercolor-theme",
  --   config = function()
  --     vim.g.PaperColor_Theme_Options = {
  --       theme = {
  --         default = {
  --           transparent_background = 1,
  --         },
  --       },
  --     }
  --   end,
  -- },

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
      colorscheme = "moonfly",
    },
  },
}
