local config = require("flix.config")

local M = {}

--- run `java -jar <jar> <cmd>` from the Flix project root in a terminal split
--- works without the LSP being attached: the root is found from `root_markers`
---@param cmd string the Flix CLI subcommand, e.g. "run" or "test"
function M.flix_cmd(cmd)
  local o = config.options
  local root = vim.fs.root(0, o.root_markers)
  if root == nil then
    vim.notify(
      "no " .. table.concat(o.root_markers, "/") .. " found in any parent directory",
      vim.log.levels.ERROR,
      { title = "flix.nvim" }
    )
    return
  end

  -- validate the jar location; a missing flix.jar prints a message
  local jar = config.resolve_jar(root)
  if jar == nil then
    vim.notify(
      o.jar .. " not found in " .. root .. "; place flix.jar there or set `jar` in setup().",
      vim.log.levels.ERROR,
      { title = "flix.nvim" }
    )
    return
  end

  vim.cmd("belowright split")
  local term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, term_buf)

  vim.fn.jobstart({ o.java, "-jar", jar, cmd }, {
    term = true,
    cwd = root,
  })
end

return M
