-- add `flix` as a filetype
vim.filetype.add({
  extension = {
    flix = "flix",
  }
})

-- auto commands
local flix = vim.api.nvim_create_augroup("flix.ft", { clear = true })
local flix_lsp = vim.api.nvim_create_augroup("flix.lsp", { clear = true })
-- enter flix buffer
vim.api.nvim_create_autocmd("FileType", {
  group = flix,
  pattern = "flix",
  callback = function(args)
    vim.api.nvim_clear_autocmds({ group = flix_lsp, buffer = args.buf }) -- prevent duplicates
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.bo.commentstring = "// %s"
    -- refresh codelens
    vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
      group = flix_lsp,
      buffer = args.buf,
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = args.buf })
      end
    })
  end
})
