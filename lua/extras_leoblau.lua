------------------------------------------------------------------
-- compilar y ejecutar
-- Guarda el archivo si está modificado
-- Reutiliza una terminal si ya existe
-- Envia el nuevo comando a esa terminal
-- Funciona para C, Python, Go, Lua
-- Muestra errores de compilación en quickfix si es C
-- Ejecutar código según tipo de archivo, abre panel único de salida

local runner = require "runner"

vim.keymap.set("n", "<leader>ex", runner.run_file, { desc = "Ejecutar archivo actual" })

-- Go
vim.keymap.set("n", "<leader>gn", runner.run_test_under_cursor, { desc = "Go: test bajo cursor" })
vim.keymap.set("n", "<leader>ga", runner.run_tests_in_file, { desc = "Go: todos los tests del archivo" })
vim.keymap.set("n", "<leader>gA", function()
    runner.run_tests_in_file(true)
end, { desc = "Go: tests archivo (verbose)" })

-- Python
--vim.keymap.set('n', '<leader>pt', runner.run_pytest_under_cursor, { desc = 'Py: test bajo cursor' })
vim.keymap.set("n", "<leader>pa", runner.run_pytests_in_file, { desc = "Py: todos los tests del archivo" })

-- Cerrar panel de ejecución con <leader>ec
vim.keymap.set("n", "leader>ec", function()
    if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
        vim.api.nvim_win_close(vim.g.runner_win, true)
        vim.g.runner_win = nil
    else
        print "No hay panel de ejecución activo"
    end
end)

