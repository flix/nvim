local M = {}

function M.setup(opts)
  if not vim.lsp.config["flix"] then
    vim.lsp.config('flix', opts or {
      cmd = { "java", "-jar", "flix.jar", "lsp" },
      filetypes = { "flix" },
      root_markers = { "flix.toml" },
      cmd_cwd = vim.fs.root(0, { 'flix.toml' }),
      root_dir = vim.fs.root(0, { 'flix.toml' }),
    })
  end
end

return M
