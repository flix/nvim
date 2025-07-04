local M = {}

function M.flix_cmd(cmd)
  local root = vim.lsp.buf.list_workspace_folders()[1]
  if root == nil then
    return nil
  end

  vim.cmd("belowright split")
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, term_buf)

  vim.fn.jobstart({ "java", "-jar", "flix.jar", cmd}, {
    term = true,
    cwd = root,
  })
end

return M
