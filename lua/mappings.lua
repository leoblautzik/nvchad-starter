require "nvchad.mappings"

-- add yours here

local runner = require "runner"
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
map("n", "<leader><leader>", "<cmd> Telescope buffers <cr>", { desc = "Find Buffers" })

-- Mover líneas o bloques con Alt+j / Alt+k

-- Normal mode: mover línea actual
map("n", "<leader>j", ":m .+1<CR>==", { silent = true, desc = "Mover línea abajo" })
map("n", "<leader>k", ":m .-2<CR>==", { silent = true, desc = "Mover línea arriba" })

-- Visual mode: mover bloque seleccionado
map("v", "<leader>j", ":m '>+1<CR>gv=gv", { silent = true, desc = "Mover bloque abajo" })
map("v", "<leader>k", ":m '<-2<CR>gv=gv", { silent = true, desc = "Mover bloque arriba" })

-- Insert mode: mover línea actual sin salir de insert
map("i", "<leader>j", "<Esc>:m .+1<CR>==gi", { silent = true, desc = "Mover línea abajo" })
map("i", "<leader>k", "<Esc>:m .-2<CR>==gi", { silent = true, desc = "Mover línea arriba" })

map("n", "<leader>ex", runner.run_file, { desc = "Ejecutar archivo actual" })

-- Go
map("n", "<leader>gn", runner.run_test_under_cursor, { desc = "Go: test bajo cursor" })
map("n", "<leader>ga", runner.run_tests_in_file, { desc = "Go: todos los tests del archivo" })
map("n", "<leader>gA", function()
    runner.run_tests_in_file(true)
end, { desc = "Go: tests archivo (verbose)" })

-- Python
--vim.keymap.set('n', '<leader>pt', runner.run_pytest_under_cursor, { desc = 'Py: test bajo cursor' })
map("n", "<leader>pa", runner.run_pytests_in_file, { desc = "Py: todos los tests del archivo" })

-- Cerrar panel de ejecución con <leader>ec
map("n", "leader>ec", function()
    if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
        vim.api.nvim_win_close(vim.g.runner_win, true)
        vim.g.runner_win = nil
    else
        print "No hay panel de ejecución activo"
    end
end)
