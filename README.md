# flix.nvim

- Neovim support for [Flix](https://flix.dev/)

## Requirements

- **Neovim 0.11+** — uses the native `vim.lsp.config` / `vim.lsp.enable` API introduced in 0.11.
- **Java 21+** in your `PATH` (Flix runs on the JVM).
- **flix.jar** in your project root (or set an absolute path via `jar`, see [Configuration](#configuration)).

Run `:checkhealth flix` to verify your setup.

## Functionality

Flix leverages LSP for syntax highlighting via **semantic tokens**, which Neovim
enables automatically when the server attaches — no extra configuration needed.

This plugin serves three main purposes:

1. create an LSP configuration for Flix
2. set the `flix` filetype and language defaults (see [ftplugin/flix.lua](ftplugin/flix.lua))
3. Lua functions for interacting with the Flix CLI

## Installation

Install with your plugin manager of choice using the repo `flix/nvim`.

Neovim 0.12 ships a built-in plugin manager, so no third party is required:

```lua
-- Neovim 0.12+ (vim.pack)
vim.pack.add({ "https://github.com/flix/nvim" })

require("flix").setup()
vim.lsp.enable("flix")
```

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "flix/nvim",
  ft = "flix",
  config = function()
    require("flix").setup()
    vim.lsp.enable("flix")
  end,
}
```

## LSP

Call `require("flix").setup()` to register the config, then enable the server:

```lua
-- create the Flix LSP config
require("flix").setup()
-- enable the server
vim.lsp.enable("flix")
```

### Configuration

`setup()` accepts an options table (all fields optional):

```lua
require("flix").setup({
  java = "java",              -- executable used to launch the jar
  jar = "flix.jar",           -- relative paths resolve from the project root
  root_markers = { "flix.toml" },
  terminal = {                -- how `flix_cmd` opens its terminal
    window = "split",         -- "split" (default) or "float" (floating window)
    width = 0.60,             -- float = fraction of editor, integer = columns
    height = 0.5,             -- float = fraction of editor, integer = rows
    pos_x = "center",         -- number or "center" (float = fraction of width)
    pos_y = "center",         -- number or "center" (float = fraction of height)
    close_binding = "q",      -- Normal-mode key that closes the floating window
  },
  features = {
    codelens = true,          -- refresh code lenses while editing
    completion = false,       -- native autocompletion (see below)
  },
  lsp = {                     -- merged into vim.lsp.config("flix", ...)
    -- settings = { ... },
  },
})
```

### Floating terminal

By default `flix_cmd` opens in a `belowright split`. Set `terminal.window = "float"`
to open it in a floating window instead. The remaining `terminal` fields only
apply to the float: `width`/`height` accept a fraction of the editor size (e.g.
`0.5`) or an integer column/row count, `pos_x`/`pos_y` accept a number or
`"center"`, and `close_binding` (default `q`) closes the window from Normal mode.

### Native completion (Neovim 0.11+)

Set `features.completion = true` to get insert-mode autocompletion straight from
the LSP — no `nvim-cmp` / `blink.cmp` required. Leave it `false` (the default) if
you already drive completion with one of those plugins to avoid duplicate menus.

In Neovim 0.12 the built-in LSP client also supports `inlineCompletion`,
`onTypeFormatting`, and `linkedEditingRange`. They will activate automatically when
the Flix server advertises them (`:help lsp` for details).

## Commands

Set local Flix keybindings with an autocommand or by creating `ftplugin/flix.lua`
in your own config. The example below maps run/test for a Flix project:

```lua
-- import the `flix_cmd` function
local flix_cmd = require("flix.commands").flix_cmd
-- setting `buffer` keeps the mappings scoped to Flix buffers
local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set("n", "<Space>br", function() flix_cmd("run") end,
  { noremap = true, silent = true, buffer = bufnr, desc = "run flix project" })
vim.keymap.set("n", "<Space>bt", function() flix_cmd("test") end,
  { noremap = true, silent = true, buffer = bufnr, desc = "test flix project" })
```

`flix_cmd` finds the project root from `root_markers`, so it works even when the
LSP is not attached, and reports an error if no `flix.toml` is found.

## Full setup example (for lazy.nvim)

```lua
{
  "flix/nvim",
  ft = "flix",
  config = function()
    -- show lsp diagnostics by highlighting line numbers
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "ErrorMsg",
          [vim.diagnostic.severity.WARN] = "WarningMsg",
        },
      },
      severity_sort = true,
    })

    -- buffer-local LSP mappings
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("my.lsp", {}),
      callback = function(args)
        local function get_opts(desc)
          return { desc = desc, buffer = args.buf, noremap = true, silent = true }
        end
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method("textDocument/formatting") then
          vim.keymap.set("n", "<space>=", vim.lsp.buf.format, get_opts("format buffer"))
        end
        if client:supports_method("textDocument/rename") then
          vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, get_opts("rename"))
        end
        vim.keymap.set("n", "<space>ee", vim.diagnostic.open_float, get_opts("diagnostic open float"))
      end,
    })

    -- register the flix lsp config and enable it
    require("flix").setup()
    vim.lsp.enable("flix")
  end,
}
```
