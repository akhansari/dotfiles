return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "Issafalcon/neotest-dotnet",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {},
        ["neotest-vitest"] = {
          -- filter_dir = function(name, rel_path, root)
          --   return name ~= "node_modules"
          -- end,
        },
        ["neotest-dotnet"] = {},
      },
    },
  },
}

-- jestCommand = "pnpm test --",
-- jestConfigFile = function(filePath)
--   local dirPath = filePath:gsub("\\", "/"):match("(.*/)")
--   local configPath = vim.fn.findfile("jest.config.js", dirPath .. ";"):gsub("\\", "/")
--   local fullPath = vim.fn.getcwd():gsub("\\", "/") .. "/" .. configPath
--   require("notify")(fullPath)
--   return fullPath
-- end,
-- cwd = function(filePath)
--   local dirPath = filePath:gsub("\\", "/"):match("(.*/)")
--   local configPath = vim.fn.findfile("jest.config.js", dirPath .. ";"):gsub("\\", "/")
--   local fullPath = vim.fn.getcwd():gsub("\\", "/") .. "/" .. configPath:match("(.*/)")
--   require("notify")(fullPath)
--   return fullPath
--   --   local dirPath = filePath:match("(.*\\)")
--   --   local configPath = vim.fn.findfile("jest.config.js", dirPath .. ";"):match("(.*\\)")
--   --   local fullPath = vim.fn.getcwd() .. "\\" .. configPath
--   --   require("notify")(fullPath)
--   --   return fullPath
-- end,
