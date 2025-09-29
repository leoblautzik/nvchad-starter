local options = {
    formatters_by_ft = {
        lua = { "stylua" },
        -- py = {
        --     "ruff",
        --     "mypy",
        --     "autopep8"
        -- },
        python = { "ruff_format" },
        go = {
            "goimports-reviser",
            "gofumpt",
            "golines",
        },
        -- c = { "clang-format" },
        -- css = { "prettier" },
        -- html = { "prettier" },
    },
    --},

    format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_fallback = true,
    },
}
return options
