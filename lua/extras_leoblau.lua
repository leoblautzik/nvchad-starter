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
vim.keymap.set("n", "<leader>et", runner.run_test_under_cursor, { desc = "Go: test bajo cursor" })
vim.keymap.set("n", "<leader>ea", runner.run_tests_in_file, { desc = "Go: todos los tests del archivo" })
vim.keymap.set("n", "<leader>eA", function()
  runner.run_tests_in_file(true)
end, { desc = "Go: tests archivo (verbose)" })

-- Python
--vim.keymap.set('n', '<leader>pt', runner.run_pytest_under_cursor, { desc = 'Py: test bajo cursor' })
vim.keymap.set("n", "<leader>pa", runner.run_pytests_in_file, { desc = "Py: todos los tests del archivo" })

-- Cerrar panel de ejecución con <leader>ec
vim.keymap.set("n", "C-q", function()
  if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
    vim.api.nvim_win_close(vim.g.runner_win, true)
    vim.g.runner_win = nil
  else
    print "No hay panel de ejecución activo"
  end
end)

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
-- Floating terminal con resize dinámico
vim.keymap.set("n", "<space>ft", function()
  local buf = vim.api.nvim_create_buf(false, true)

  local function open_float()
    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    return vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
    })
  end

  local win = open_float()
  vim.fn.termopen(vim.o.shell)
  vim.cmd.startinsert()

  -- Cerrar con <Esc>
  vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:q<CR>", { buffer = buf })

  -- Auto-resize si la ventana cambia
  vim.api.nvim_create_autocmd("VimResized", {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      win = open_float()
      vim.cmd.startinsert()
    end,
  })
end, { desc = "Open floating terminal" })

------------------------------------------------------------------
-- Small terminal (cerrar con Ctrl+q)
-- vim.keymap.set('n', '<space>st', function()
--   vim.cmd.vnew()
--   vim.cmd.term()
--   vim.cmd.wincmd 'J'
--   vim.cmd.startinsert()
--   vim.api.nvim_win_set_height(0, 5)
--
--   local buf = vim.api.nvim_get_current_buf()
--
--   -- Ctrl+q para cerrar terminal
--   vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:q<CR>', { buffer = buf })
-- end, { desc = 'Open small terminal' })
------------------------------------------------------------------
------------------------------------------------------------------
-- Small terminal (30% del espacio del tabpage, resizing automático, Ctrl-q para cerrar)
vim.keymap.set("n", "<space>st", function()
  -- calcula la altura total visible (suma de ventanas normales en la tabpage)
  local function total_tabpage_height()
    local total = 0
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      total = total + vim.api.nvim_win_get_height(w)
    end
    return total
  end

  -- calcular altura objetivo ANTES de crear la ventana nueva
  local total_before = total_tabpage_height()
  local term_h = math.max(3, math.floor(total_before * 0.3))

  -- crear split abajo con la altura calculada
  vim.cmd(string.format("belowright %d split", term_h))
  vim.cmd.term(vim.o.shell) -- lanzar terminal en esa ventana
  local term_win = vim.api.nvim_get_current_win()
  local term_buf = vim.api.nvim_get_current_buf()
  vim.cmd.startinsert()

  -- Ctrl+q (modo terminal) para cerrar la ventana del terminal
  vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:close<CR>", { buffer = term_buf, desc = "Close small terminal" })

  -- crear un augroup único para este terminal (permite limpiar los autocmds cuando se cierra)
  local group_name = "SmallTerm_" .. tostring(term_buf)
  vim.api.nvim_create_augroup(group_name, { clear = true })

  -- autocmd global que reajusta la altura cuando cambia el layout / tamaño
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = group_name,
    callback = function()
      -- si la ventana ya no existe, borrar el augroup y salir
      if not vim.api.nvim_win_is_valid(term_win) then
        pcall(vim.api.nvim_del_augroup_by_name, group_name)
        return
      end

      -- recalcular altura total y setear 30%
      local total = total_tabpage_height()
      local new_h = math.max(3, math.floor(total * 0.3))
      if vim.api.nvim_win_is_valid(term_win) then
        pcall(vim.api.nvim_win_set_height, term_win, new_h)
      end
    end,
  })
end, { desc = "Open small terminal (30%, C-q to close)" })
