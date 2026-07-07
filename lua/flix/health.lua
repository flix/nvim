local M = {}

--- `:checkhealth flix` entry point
function M.check()
  local health = vim.health
  health.start("flix.nvim")

  -- Neovim version
  if vim.fn.has("nvim-0.11") == 1 then
    health.ok("Neovim " .. tostring(vim.version()))
  else
    health.error("Neovim 0.11 or newer is required")
  end

  -- setup() called?
  if require("flix").did_setup then
    health.ok("require('flix').setup() has been called")
  else
    health.warn("require('flix').setup() has not been called", {
      "Add `require('flix').setup()` then `vim.lsp.enable('flix')` to your config",
    })
  end

  local o = require("flix.config").options

  -- java executable
  if vim.fn.executable(o.java) == 1 then
    health.ok("java executable '" .. o.java .. "' found on PATH")
  else
    health.error("java executable '" .. o.java .. "' not found on PATH", {
      "Install a JDK (Flix requires Java 21+) and ensure it is on your PATH",
    })
  end

  -- flix jar
  local root = vim.fs.root(0, o.root_markers) or vim.fn.getcwd()
  local found = require("flix.config").resolve_jar(root)
  if found then
    health.ok("flix jar found at " .. found)
  else
    health.warn("flix jar '" .. o.jar .. "' not found near " .. root, {
      "Place flix.jar in your project root, or set `jar` to an absolute path in setup()",
    })
  end
end

return M
