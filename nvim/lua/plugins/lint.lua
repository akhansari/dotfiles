return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", "~/.config/.markdownlint-cli2.yaml", "--" },
        },
      },
    },
  },
}
