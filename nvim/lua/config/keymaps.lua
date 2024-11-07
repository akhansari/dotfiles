-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

vim.keymap.set({ "n", "v" }, "u", "h", { desc = "Left" })
vim.keymap.set({ "n", "v" }, "U", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v" }, "i", "j", { desc = "Down" })
vim.keymap.set({ "n", "v" }, "p", "k", { desc = "Up" })
vim.keymap.set({ "n", "v" }, "e", "l", { desc = "Right" })
vim.keymap.set({ "n", "v" }, "E", "$", { desc = "Go to end of line" })

vim.keymap.set("n", "h", "u", { desc = "Undo" })
vim.keymap.set("n", "H", "<C-r>", { desc = "Undo" })
vim.keymap.set("n", "l", "i", { desc = "Insert" })
vim.keymap.set("n", "L", "I", { desc = "Insert" })
vim.keymap.set({ "n", "x" }, "k", "p", { desc = "Paste" })
vim.keymap.set({ "n", "x" }, "K", "P", { desc = "Paste" })
vim.keymap.set({ "n", "v" }, "j", "e", { desc = "End word" })
-- vim.keymap.set({ "n", "v" }, "J", "E", { desc = "End word" })

vim.keymap.set("n", "<C-u>", "<C-h>", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<C-i>", "<C-j>", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<C-p>", "<C-k>", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<C-e>", "<C-l>", { desc = "Go to right window", remap = true })

-- vim.keymap.set("n", "<C-j>", "<C-i>", { desc = "" })

vim.keymap.set("n", "Q", "@@")

vim.keymap.set({ "n", "v" }, "à", "%", { desc = "Next word" })

vim.keymap.set("n", "P", "gK", { desc = "Signature help", remap = true })
vim.keymap.set("n", "I", "K", { desc = "Hover", remap = true })

vim.keymap.set("n", "éé", "]]", { desc = "Next Reference", remap = true })
vim.keymap.set("n", "ée", "]e", { desc = "Next Error", remap = true })
vim.keymap.set("n", "éw", "]w", { desc = "Next Warning", remap = true })
vim.keymap.set("n", "éd", "]d", { desc = "Next Diagnostic", remap = true })
vim.keymap.set("n", "éq", "]q", { desc = "Next Quickfix", remap = true })
vim.keymap.set("n", "éb", "]b", { desc = "Next Buffer", remap = true })

vim.keymap.set("n", "éc", "]c", { desc = "Next Class start", remap = true })
vim.keymap.set("n", "éC", "]C", { desc = "Next Class end", remap = true })
vim.keymap.set("n", "éf", "]f", { desc = "Next Function start", remap = true })
vim.keymap.set("n", "éF", "]F", { desc = "Next Function end", remap = true })
vim.keymap.set("n", "ém", "]m", { desc = "Next Method start", remap = true })
vim.keymap.set("n", "éM", "]M", { desc = "Next Method end", remap = true })
vim.keymap.set("n", "éi", "]i", { desc = "Next Indent", remap = true })

vim.keymap.set("n", "çç", "[[", { desc = "Prev Reference", remap = true })
vim.keymap.set("n", "çe", "[e", { desc = "Prev Error", remap = true })
vim.keymap.set("n", "çw", "[w", { desc = "Prev Warning", remap = true })
vim.keymap.set("n", "çd", "[d", { desc = "Prev Diagnostic", remap = true })
vim.keymap.set("n", "çq", "[q", { desc = "Prev Quickfix", remap = true })
vim.keymap.set("n", "çb", "[b", { desc = "Prev Buffer", remap = true })

vim.keymap.set("n", "çc", "[c", { desc = "Prev Class start", remap = true })
vim.keymap.set("n", "çC", "[C", { desc = "Prev Class end", remap = true })
vim.keymap.set("n", "çf", "[f", { desc = "Prev Function start", remap = true })
vim.keymap.set("n", "çF", "[F", { desc = "Prev Function end", remap = true })
vim.keymap.set("n", "çm", "[m", { desc = "Prev Method start", remap = true })
vim.keymap.set("n", "çM", "[M", { desc = "Prev Method end", remap = true })
vim.keymap.set("n", "çi", "[i", { desc = "Prev Indent", remap = true })

vim.keymap.set("n", "<leader>se", require("telescope").extensions.live_grep_args.live_grep_args, { desc = "RipGrep" })

vim.keymap.set(
  { "n" },
  "<leader>pu",
  require("package-info").update,
  { silent = true, noremap = true, desc = "Update package" }
)
vim.keymap.set(
  { "n" },
  "<leader>pd",
  require("package-info").delete,
  { silent = true, noremap = true, desc = "Delete package" }
)
vim.keymap.set(
  { "n" },
  "<leader>pi",
  require("package-info").install,
  { silent = true, noremap = true, desc = "Install package" }
)
vim.keymap.set(
  { "n" },
  "<leader>pp",
  require("package-info").change_version,
  { silent = true, noremap = true, desc = "Change package version" }
)
