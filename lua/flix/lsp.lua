local config = require("flix.config")

local M = {}

-- Single augroup for code lens refresh autocommands; cleared per-buffer so
-- attaching to one buffer never wipes another buffer's autocommands.
local codelens_group = vim.api.nvim_create_augroup("flix.codelens", { clear = false })

--- Keep code lenses fresh for a buffer.
---
--- Nvim 0.12+ provides a self-refreshing provider via `codelens.enable`; on
--- 0.11 we fall back to refreshing manually on the usual edit/enter events.
--- (`codelens.refresh` is deprecated and warns from 0.12 onward, so it must
--- only be reached when `enable` is unavailable.)
---@param bufnr integer
local function setup_codelens(bufnr)
  if vim.lsp.codelens.enable then
    vim.lsp.codelens.enable(true, { bufnr = bufnr })
    return
  end

  vim.api.nvim_clear_autocmds({ group = codelens_group, buffer = bufnr })
  vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
    group = codelens_group,
    buffer = bufnr,
    callback = function()
      vim.lsp.codelens.refresh({ bufnr = bufnr })
    end,
  })
  vim.lsp.codelens.refresh({ bufnr = bufnr })
end

--- Wire up buffer-local LSP features when the Flix client attaches.
---@param client vim.lsp.Client
---@param bufnr integer
function M.on_attach(client, bufnr)
  local features = config.options.features

  if features.codelens and client:supports_method("textDocument/codeLens") then
    setup_codelens(bufnr)
  end

  if features.completion and client:supports_method("textDocument/completion") then
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
  end
end

return M
