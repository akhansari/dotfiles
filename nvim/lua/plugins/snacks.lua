return {
  {
    "folke/snacks.nvim",
    ---@module "snacks"
    ---@type snacks.Config
    opts = {

      picker = {

        layout = { preset = "ivy_split" },

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
            -- layout = { preview = { main = true, enabled = false } },
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

      notifier = {
        timeout = 5000,
      },

      styles = {
        notification = {
          wo = {
            wrap = true,
          },
        },
      },

      dashboard = {
        preset = {
          header = [[
  🟩🟩🟩🟩    
🟩🔳🟩🔳🟩    
🟩🟩🟩🟩🟩    
    ⬛⬛🟩    
  🟩⬜🟩🟩  🟩
    ⬜⬜🟩🟩🟩
    ⬜⬜🟩🟩  
    🟩  🟩    
]],
        },
      },
    },
  },
}
