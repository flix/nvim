local config = require("flix.config")

local M = {}

--- resolve a size spec to an integer number of cells
--- a whole number is used as-is (columns/rows); a fractional value is a fraction of `total`
--- @param spec number
--- @param total integer
--- @return integer
local function resolve_size(spec, total)
  if spec % 1 ~= 0 then
    return math.max(1, math.floor(spec * total))
  end
  return spec
end

--- resolve a position spec to an integer cell offset
--- "center" centers a window of `size` cells within `total`;
--- a whole number is used as-is; a fractional value is a fraction of `total`
--- @param spec number|string
--- @param total integer
--- @param size integer
--- @return integer
local function resolve_pos(spec, total, size)
  if spec == "center" then
    return math.floor((total - size) / 2)
  end
  if type(spec) == "number" and spec % 1 ~= 0 then
    return math.floor(spec * total)
  end
---@diagnostic disable-next-line: return-type-mismatch
  return spec
end

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

  local t = o.terminal

  if t.window == "float" then
    local term_buf = vim.api.nvim_create_buf(false, true)

    local total_cols = vim.o.columns
    local total_rows = vim.o.lines

    local width = resolve_size(t.width, total_cols)
    local height = resolve_size(t.height, total_rows)
    local col = resolve_pos(t.pos_x, total_cols, width)
    local row = resolve_pos(t.pos_y, total_rows, height)

    vim.api.nvim_open_win(term_buf, true, {
      relative = "win",
      width = width,
      height = height,
      row = row,
      col = col,
      title = "Flix Run",
      title_pos = "center",
      border = "single"
    })

    vim.keymap.set("n", t.close_binding, "<Cmd>bdelete!<CR>", { buffer = term_buf, silent = true })
  else
    vim.cmd("belowright split")
    local term_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, term_buf)
  end

  vim.fn.jobstart({ o.java, "-jar", jar, cmd }, {
    term = true,
    cwd = root,
  })
end

return M
