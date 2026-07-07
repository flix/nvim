local config = require("flix.config")

local M = {}

-- set to true once setup() has run successfully (used by :checkhealth flix).
M.did_setup = false

-- remember which problems we've already reported so a missing JDK or jar is
-- flagged once
local warned = {}

--- notify the user at most once per distinct `key`
---@param key string
---@param msg string
local function warn_once(key, msg)
  if warned[key] then
    return
  end
  warned[key] = true
  vim.notify(msg, vim.log.levels.WARN, { title = "flix.nvim" })
end

--- register the Flix LSP configuration
---@param opts table|nil see lua/flix/config.lua for available fields
function M.setup(opts)
  if vim.fn.has("nvim-0.11") == 0 then
    vim.notify("Requires Neovim 0.11 or newer", vim.log.levels.ERROR, { title = "flix.nvim" })
    return
  end

  local o = config.set(opts)

  local lsp = vim.tbl_deep_extend("force", {
    cmd = function(dispatchers)
      local root = vim.fs.root(0, o.root_markers) or vim.fn.getcwd()
      local jar = config.resolve_jar(root) or o.jar
      return vim.lsp.rpc.start({ o.java, "-jar", jar, "lsp" }, dispatchers, { cwd = root })
    end,
    filetypes = { "flix" },
    root_dir = function(bufnr, on_dir)
      local root = vim.fs.root(bufnr, o.root_markers)
      if not root then
        return
      end
      if vim.fn.executable(o.java) == 0 then
        warn_once(
          "java:" .. o.java,
          ("'%s' was not found on PATH, so the language server was not started. "):format(o.java)
            .. "Install a JDK (Flix needs Java 21+) or set `java` in setup()."
        )
        return
      end
      if not config.resolve_jar(root) then
        warn_once(
          "jar:" .. root,
          ("%s was not found in %s, so the language server was not started. "):format(o.jar, root)
            .. "Place flix.jar there or set `jar` to its path in setup(). Run :checkhealth flix for details."
        )
        return
      end
      -- prerequisites met: forget any earlier complaint and activate the client
      warned["java:" .. o.java] = nil
      warned["jar:" .. root] = nil
      on_dir(root)
    end,
    root_markers = o.root_markers,
  }, o.lsp)

  vim.lsp.config("flix", lsp)
  M.did_setup = true
end

return M
