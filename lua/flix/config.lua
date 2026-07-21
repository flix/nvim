local M = {}

---@class flix.TerminalOptions
---@field window "float"|"split" how the terminal is opened
---@field width number integer = columns; float in (0,1) = fraction of editor width
---@field height number integer = rows; float in (0,1) = fraction of editor height
---@field pos_x number|"center" integer = columns from left; float = fraction of editor width; "center" = centered on x
---@field pos_y number|"center" integer = rows from top; float = fraction of editor height; "center" = centered on y
---@field close_binding string Normal-mode key that closes the terminal window

---@class flix.Config
---@field java string path or name of the java executable
---@field jar string path to flix.jar, relative to the project root or absolute
---@field root_markers string[] files used to detect the project root
---@field terminal flix.TerminalOptions options for the floating terminal window
---@field features table feature flags
---@field lsp table options forwarded to `vim.lsp.config("flix", ...)`

-- default configuration
-- override any field via `require("flix").setup({ ... })`
---@type flix.Config
M.defaults = {
  java = "java",
  jar = "flix.jar",
  root_markers = { "flix.toml" },
  terminal = {
    window = "split",
    width = 0.60,
    height = 0.5,
    pos_x = "center",
    pos_y = "center",
    close_binding = "q"
  },
  features = {
    codelens = true,
    completion = false,
  },
  lsp = {},
}

-- active configuration
---@type flix.Config
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
