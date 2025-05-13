local snacks = require("snacks")

return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {

      picker = {

        win = {
          list = {
            keys = {
              ["i"] = "list_down",
              ["p"] = "list_up",
            },
          },
          input = {
            keys = {
              ["i"] = "list_down",
              ["p"] = "list_up",
            },
          },
        },

        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["p"] = "list_up",
                  ["k"] = "explorer_paste",
                },
              },
            },
          },
        },
      },
    },
  },
}
