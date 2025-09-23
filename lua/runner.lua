-- compilar y ejecutar
-- Guarda el archivo si está modificado
-- Reutiliza una terminal si ya existe
-- Envia el nuevo comando a esa terminal
-- Funciona para C, Python, Go, Lua
-- Muestra errores de compilación en quickfix si es C
-- Ejecutar código según tipo de archivo, abre panel único de salida

local M = {}

-- Crear terminal temporal en split inferior y ejecutar comando
local function run_cmd_output(cmd, cwd)
  if vim.g.runner_win and vim.api.nvim_win_is_valid(vim.g.runner_win) then
    vim.api.nvim_win_close(vim.g.runner_win, true)
  end
  local buf = vim.api.nvim_create_buf(false, true)
  local win_height = 12
  vim.cmd("botright " .. win_height .. "split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  vim.g.runner_win = win
  vim.fn.termopen(cmd, {
    cwd = cwd,
    on_exit = function()
      vim.api.nvim_buf_set_option(buf, "modifiable", false)
    end,
  })
end

----------------------------------------------------------------------
-- Ejecutar archivo actual según su tipo
----------------------------------------------------------------------
function M.run_file()
  if vim.bo.modified then
    vim.cmd "write"
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  local file_type = vim.bo.filetype

  if file_type == "lua" then
    run_cmd_output({ "lua", file_name }, vim.fn.expand "%:p:h")
  elseif file_type == "c" then
    local out = "/tmp/a.out"
    local compile_cmd = { "gcc", file_name, "-o", out }
    local compile_result = vim.fn.system(compile_cmd)
    if vim.v.shell_error ~= 0 then
      print("Error de compilación:\n" .. compile_result)
    else
      run_cmd_output({ out }, vim.fn.expand "%:p:h")
    end
  elseif file_type == "python" then
    run_cmd_output({ "python3", file_name }, vim.fn.expand "%:p:h")
  elseif file_type == "go" then
    local file_dir = vim.fn.expand "%:p:h"
    local gomod = vim.fn.findfile("go.mod", file_dir .. ";")
    local dir = gomod ~= "" and vim.fn.fnamemodify(gomod, ":h") or file_dir

    if file_name:match "_test%.go$" then
      run_cmd_output({ "go", "test" }, file_dir) -- todos los tests del paquete
    else
      run_cmd_output({ "go", "run", file_name }, dir)
    end
  else
    print "Formato no soportado"
  end
end

----------------------------------------------------------------------
-- GO: Ejecutar test bajo el cursor
----------------------------------------------------------------------
function M.run_test_under_cursor()
  if vim.bo.modified then
    vim.cmd "write"
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match "_test%.go$" then
    print "Este comando solo funciona en archivos *_test.go"
    return
  end

  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  local test_name = nil

  while node do
    if node:type() == "function_declaration" then
      local id = node:field("name")[1]
      if id then
        test_name = vim.treesitter.get_node_text(id, 0)
      end
      break
    end
    node = node:parent()
  end

  if not test_name or not test_name:match "^Test" then
    print "No se detectó una función de test aquí"
    return
  end

  local file_dir = vim.fn.expand "%:p:h"
  run_cmd_output({ "go", "test", "-run", test_name }, file_dir)
end

----------------------------------------------------------------------
-- GO: Ejecutar todos los tests del archivo actual
----------------------------------------------------------------------
function M.run_tests_in_file(verbose)
  if vim.bo.modified then
    vim.cmd "write"
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match "_test%.go$" then
    print "Este comando solo funciona en archivos *_test.go"
    return
  end

  -- Extraer nombres de test (func TestXxx)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local tests = {}
  for _, line in ipairs(lines) do
    local name = line:match "^func%s+(Test%w+)"
    if name then
      table.insert(tests, name)
    end
  end

  if #tests == 0 then
    print "No se encontraron tests en este archivo"
    return
  end

  -- Construir regex para go test -run
  local pattern = "^(" .. table.concat(tests, "|") .. ")$"
  local file_dir = vim.fn.expand "%:p:h"

  local cmd = { "go", "test", "-run", pattern }
  if verbose then
    table.insert(cmd, "-v")
  end

  run_cmd_output(cmd, file_dir)
end

----------------------------------------------------------------------
-- PYTHON: Ejecutar test bajo el cursor (pytest)
----------------------------------------------------------------------
function M.run_pytest_under_cursor()
  if vim.bo.modified then
    vim.cmd "write"
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match "_test%.py$" then
    print "Este comando solo funciona en archivos *_test.py"
    return
  end

  local ts_utils = require "nvim-treesitter.ts_utils"
  local node = ts_utils.get_node_at_cursor()
  local test_name = nil

  while node do
    if node:type() == "function_definition" then
      local id = node:field("name")[1]
      if id then
        test_name = vim.treesitter.get_node_text(id, 0)
      end
      break
    end
    node = node:parent()
  end

  if not test_name or not test_name:match "^test" then
    print "No se detectó una función de test aquí"
    return
  end

  local file_dir = vim.fn.expand "%:p:h"
  run_cmd_output({ "pytest", file_name .. "::" .. test_name }, file_dir)
end

----------------------------------------------------------------------
-- PYTHON: Ejecutar todos los tests del archivo actual
----------------------------------------------------------------------
function M.run_pytests_in_file()
  if vim.bo.modified then
    vim.cmd "write"
  end

  local file_name = vim.api.nvim_buf_get_name(0)
  if not file_name:match "_test%.py$" then
    print "Este comando solo funciona en archivos *_test.py"
    return
  end

  local file_dir = vim.fn.expand "%:p:h"
  run_cmd_output({ "pytest", "-v", file_name }, file_dir)
end

return M
