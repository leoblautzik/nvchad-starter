require "nvchad.mappings"

-- add yours here

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
