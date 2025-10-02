require "nvchad.autocmds"
require "nvchad.nvdash"
require "extras_leoblau"
require "runner"
require "terminal"

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
------------------------------------------------------------------
-- Trucos para el modo terminal
---- Sin numeros en modo terminal
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.cmd.startinsert()
    end,
})

------------------------------------------------------------------
-- Numeros de linea
---- Absoluto/relativo para line numbers
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    pattern = "*",
    callback = function()
        vim.wo.relativenumber = false
        vim.wo.number = true
    end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    pattern = "*",
    callback = function()
        vim.wo.relativenumber = true
        vim.wo.number = true
    end,
})

------------------------------------------------------------------
-- Restaurar última posición del cursor y el scroll al abrir un buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype) then
            return
        end

        -- Restaurar cursor
        if vim.fn.line [['"]] > 0 and vim.fn.line [['"]] <= vim.fn.line "$" then
            vim.fn.setpos(".", vim.fn.getpos [['"]])
            vim.cmd "normal! zv"
        end

        -- Restaurar scroll
        local view = vim.fn.winsaveview()
        vim.schedule(function()
            vim.fn.winrestview(view)
        end)
    end,
})
------------------------------------------------------------------
-- Plantille para archivos ansi C
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.c",
    callback = function()
        vim.api.nvim_buf_set_lines(0, 0, 0, false, {
            "#include <stdio.h>",
            "",
            "int main()",
            "{",
            "    return 0;",
            "}",
        })
        vim.api.nvim_win_set_cursor(0, { 4, 4 }) -- Coloca el cursor dentro de main()
    end,
})
------------------------------------------------------------------
--- Plantilla para archivos .py con la funcion main lista
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.py",
    callback = function()
        local filename = vim.fn.expand "%:t"
        -- Evita que corra en archivos de test
        if filename:match "^test_" or filename:match "_test%.py$" then
            return
        end

        vim.api.nvim_buf_set_lines(0, 0, 0, false, {
            "def main():",
            "    pass",
            "",
            'if __name__ == "__main__":',
            "    main()",
        })
        vim.api.nvim_win_set_cursor(0, { 2, 4 })
    end,
})

-- para los archivos de test_.py
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = { "test_*.py", "*_test.py" },
    callback = function()
        local filepath = vim.fn.expand "%:p"
        local relative = filepath:gsub(vim.fn.getcwd() .. "/", "")
        local parts = vim.split(relative, "/")

        local dir = parts[#parts - 1] or ""
        local file = parts[#parts] or ""

        file = file:gsub("%.py$", "")
        file = file:gsub("^test_", ""):gsub("_test$", "")

        local function to_camel(s)
            local res = {}
            for word in string.gmatch(s, "[^_]+") do
                table.insert(res, word:sub(1, 1):upper() .. word:sub(2))
            end
            return table.concat(res)
        end

        local class_name = "Test" .. to_camel(dir) .. to_camel(file)

        vim.api.nvim_buf_set_lines(0, 0, 0, false, {
            "import unittest",
            "",
            "class " .. class_name .. "(unittest.TestCase):",
            "    def test_example(self):",
            "        self.assertEqual(1 + 1, 2)",
            "",
            "if __name__ == '__main__':",
            "    unittest.main()",
        })

        vim.api.nvim_win_set_cursor(0, { 4, 8 })
    end,
})
