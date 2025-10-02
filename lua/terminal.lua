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
