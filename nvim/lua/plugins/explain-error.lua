-- Plugin to explain LSP diagnostics using Copilot Chat
-- Usage: :ExplainError or <leader>ce

local function explain_error()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1 -- 0-indexed for diagnostics API
  local diagnostics = vim.diagnostic.get(0, { lnum = line })

  if #diagnostics == 0 then
    vim.notify("No diagnostics on current line", vim.log.levels.INFO)
    return
  end

  local diag = diagnostics[1]
  local severity_map = { "Error", "Warning", "Info", "Hint" }
  local severity = severity_map[diag.severity] or "Unknown"

  local prompt = string.format(
    [[
Explain this LSP diagnostic:

**%s:** %s
**Source:** %s
**Code:** %s

Please explain succinctly:
1. What this error/warning/diagnostic means and the likely cause
2. How to fix it
3. Suggest fixed code if applicable

]],
    severity,
    diag.message,
    diag.source or "LSP",
    diag.code or "N/A"
  )

  require("CopilotChat").ask(prompt, {
    resources = { "buffer:active" },
  })
end

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  keys = {
    {
      "<leader>ce",
      explain_error,
      desc = "Explain LSP Error",
    },
  },
  init = function()
    vim.api.nvim_create_user_command("ExplainError", explain_error, {
      desc = "Explain the LSP error under cursor using Copilot",
    })
  end,
}
