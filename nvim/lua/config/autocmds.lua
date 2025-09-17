-- Autocmds are automatically loaded on the VeryLazy event

-- disable fantomas
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "fsharp" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.ts", "*.astro", "*.svelte" },
--   callback = function()
--     vim.lsp.buf.code_action({
--       apply = true,
--       context = {
--         only = { "source.organizeImports" },
--         diagnostics = {},
--       },
--     })
--   end,
-- })
