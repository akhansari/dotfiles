return {

  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    config = function()
      vim.g.moonflyTransparent = true
    end,
  },

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

  -- {
  --   "Shatur/neovim-ayu",
  --   config = function()
  --     require("ayu").setup({
  --       overrides = {
  --         Normal = { bg = "None" },
  --         NormalFloat = { bg = "none" },
  --         ColorColumn = { bg = "None" },
  --         SignColumn = { bg = "None" },
  --         Folded = { bg = "None" },
  --         FoldColumn = { bg = "None" },
  --         CursorLine = { bg = "None" },
  --         CursorColumn = { bg = "None" },
  --         VertSplit = { bg = "None" },
  --         SnacksPickerGitStatusUntracked = { fg = "#565B66" },
  --         SnacksPickerDir = { fg = "#565B66" },
  --       },
  --     })
  --   end,
  -- },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "moonfly",
    },
  },
}
