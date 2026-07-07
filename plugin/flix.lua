-- register `flix` as a filetype for *.flix files
vim.filetype.add({
  extension = {
    flix = "flix",
  },
})

-- set up buffer-local LSP features when the Flix lsp attaches
-- indentation and comment defaults live in ftplugin/flix.lua
local group = vim.api.nvim_create_augroup("flix.lsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil or client.name ~= "flix" then
      return
    end
    require("flix.lsp").on_attach(client, args.buf)
  end,
})
