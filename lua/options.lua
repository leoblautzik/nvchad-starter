require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!
-- Save undo history
o.undofile = true
-- definir el directorio donde se van a guardar los archivos de undo
o.undodir = vim.fn.stdpath "state" .. "/undo"
vim.cmd "set expandtab"
vim.cmd "set smartindent"
vim.cmd "set tabstop=4"
vim.cmd "set softtabstop=4"
vim.cmd "set shiftwidth=4"
vim.cmd "set backspace=indent,eol,start"
