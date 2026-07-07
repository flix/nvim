local M = {}

-- default configuration
-- override any field via `require("flix").setup({ ... })`
M.defaults = {
  java = "java",
  jar = "flix.jar",
  root_markers = { "flix.toml" },
  features = {
    codelens = true,
    completion = false,
  },
  lsp = {},
}

-- active configuration
M.options = vim.deepcopy(M.defaults)

--- merge user options over the defaults
---@param opts table|nil
---@return table options
function M.set(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
  return M.options
end

--- resolve the configured `jar` to an absolute path
---@param root string|nil project root used to resolve a relative jar path
---@return string|nil path absolute path to an existing jar, or nil if none found
function M.resolve_jar(root)
  local jar = vim.fs.normalize(M.options.jar)
  local candidates
  if jar:sub(1, 1) == "/" then
    candidates = { jar }
  else
    candidates = { vim.fs.normalize((root or vim.fn.getcwd()) .. "/" .. jar) }
    if root then
      candidates[#candidates + 1] = vim.fs.normalize(vim.fn.getcwd() .. "/" .. jar)
    end
  end
  for _, candidate in ipairs(candidates) do
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

return M
