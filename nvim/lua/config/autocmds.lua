-- Autocmds are automatically loaded on the VeryLazy event

-- disable fantomas
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "fsharp" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   group = vim.api.nvim_create_augroup("BiomeFixAll", { clear = true }),
--   pattern = { "*.ts", "*.svelte" },
--   callback = function()
--     vim.lsp.buf.code_action({
--       context = { only = { "source.fixAll.biome" } },
--       apply = true,
--     })
--   end,
-- })
