require("nvchad.configs.lspconfig").defaults()

local configs = require "nvchad.configs.lspconfig"

local servers = { "html", "cssls", "pyright", "pylsp", "clangd", "gopls" }
vim.lsp.enable(servers)
-- read :h vim.lsp.config for changing options of lsp servers
-- Configuraciones específicas
configs.setup = {
  -- Python: Pyright
  pyright = {
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoImportCompletions = true,
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
        },
      },
    },
  },

  -- Python: Pylsp
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          autopep8 = { enabled = false },
          yapf = { enabled = false },
          black = { enabled = false },
          pylsp_black = { enabled = false },
          pylsp_isort = { enabled = false },
          pycodestyle = { enabled = false },
          pyflakes = { enabled = false },
          mccabe = { enabled = false },

          pylsp_mypy = { enabled = true },
          pylsp_rope = { enabled = true },
          ruff = { enabled = true, format = true },
        },
      },
    },
  },

  -- Go: gopls
  gopls = {
    settings = {
      gopls = {
        analyses = { unusedparams = true },
        staticcheck = true,
        completeUnimported = true,
        usePlaceholders = true,
      },
    },
  },

  -- C/C++: clangd
  clangd = {
    cmd = { "clangd", "--background-index" },
    init_options = { clangdFileStatus = true },
  },
}

return configs
