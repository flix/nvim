# flix.nvim

- neovim support for [Flix](https://flix.dev/)

## Functionality

- Flix leverages LSP for syntax highlighting, it uses the `vim.lsp.enable` functionality introduced in nvim **versions 0.11**

- this plugin serves three main purposes
    1. create a lsp configuration for Flix
    2. set the Flix filetype and language defaults
    3. lua functions for interacting with the Flix cli

## installation

- using your package manager of choice pass in the repo
    - "flix/nvim"
    - or if using the dev fork directly use this url

## LSP

- to get the lsp setup you simply call `require("flix").setup()`
    - do this before enabling the lsp (`vim.lsp.enable("flix")`)

```lua
-- create Flix config
require("flix").setup()
-- enable server
vim.lsp.enable("flix")
```

## Commands

- you can set local Flix keybindings with an autocommand or by creating `ftplugin/flix.lua` in your configuration.
- the following example shows how to setup keybindings for running and testing a flix project in `ftplugin/flix.lua`

```lua
-- import the `flix_cmd` function
local flix_cmd = require("flix.commands").flix_cmd
-- setting `bufnr` prevents keybindings from being set to other filetypes
local bufnr = vim.api.nvim_get_current_buf()

vim.keymap.set('n', '<Space>br', function() flix_cmd("run") end,
  { noremap = true, silent = true, buffer = bufnr, desc = "run flix project" })
vim.keymap.set('n', '<Space>bt', function() flix_cmd("test") end,
  { noremap = true, silent = true, buffer = bufnr, desc = "run flix project" })
```

## lspconfig setup example

```lua
{
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
  },
  config = function()
    -- show lsp diagnostics by highlighting line numbers
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = 'ErrorMsg',
          [vim.diagnostic.severity.WARN] = 'WarningMsg',
        },
      },
      severity_sort = true,
    })

    -- customized mappings.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('my.lsp', {}),
      callback = function(args)
        local function get_opts(desc)
          return { desc = desc, buffer = args.buf, noremap = true, silent = true }
        end
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method('textDocument/format') then
          vim.keymap.set('n', '<space>=', vim.lsp.buf.format, get_opts('format buffer'))
        end
        if client:supports_method('textDocument/rename') then
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, get_opts('rename'))
        end
        vim.keymap.set('n', '<space>ee', vim.diagnostic.open_float, get_opts('diagnostic open float'))
      end
    })

    -- add flix lsp config
    require("flix").setup()

    local lsp_langs = {
      "flix",
      -- other enabled languages...
    }

    -- enable all lsp supported languages
    vim.lsp.enable(lsp_langs)
  end,
}  
```
