-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

vim.keymap.set({ "n", "v" }, "u", "h", { desc = "Left" })
vim.keymap.set({ "n", "v" }, "U", "^", { desc = "Go to beginning of line" })
vim.keymap.set({ "n", "v" }, "i", "<down>", { desc = "Down" })
vim.keymap.set({ "n", "v" }, "I", "J", { desc = "Down" })
vim.keymap.set({ "n", "v" }, "p", "k", { desc = "Up" })
vim.keymap.set({ "n", "v" }, "P", "K", { desc = "Up" })
vim.keymap.set({ "n", "v" }, "e", "l", { desc = "Right" })
vim.keymap.set({ "n", "v" }, "E", "$", { desc = "Go to end of line" })

vim.keymap.set({ "n", "v" }, "h", "u", { desc = "Undo" })
vim.keymap.set({ "n", "v" }, "H", "U", { desc = "Undo" })
vim.keymap.set({ "n", "v" }, "l", "i", { desc = "Insert" })
vim.keymap.set({ "n", "v" }, "L", "I", { desc = "Insert" })
vim.keymap.set({ "n", "v" }, "k", "p", { desc = "Paste" })
vim.keymap.set({ "n", "v" }, "K", "P", { desc = "Paste" })
vim.keymap.set({ "n", "v" }, "j", "e", { desc = "End word" })
vim.keymap.set({ "n", "v" }, "J", "E", { desc = "End word" })

vim.keymap.set("n", "<C-u>", "<C-h>", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<C-i>", "<C-j>", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<C-p>", "<C-k>", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<C-e>", "<C-l>", { desc = "Go to right window", remap = true })

-- vim.keymap.set("n", "<C-j>", "<C-i>", { desc = "" })

vim.keymap.set("n", "Q", "@@")

vim.keymap.set("n", "<A-i>", "<A-j>", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<A-p>", "<A-k>", { desc = "Go to upper window", remap = true })

vim.keymap.set({ "n", "v" }, "à", "%", { desc = "Next word" })

vim.keymap.set("n", "P", "gK", { desc = "Signature help", remap = true })

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
