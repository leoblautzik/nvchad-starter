-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
---@class MyChadrcConfig

local M = {}

M.base46 = {
  theme = "chadracula-evondev",
  transparency = false,

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}
M.plugins = {
  override = {
    ["nvim-telescope/telescope.nvim"] = {
      defaults = {
        -- Estilo de borde
        borderchars = { "╭", "╮", "╯", "╰", "─", "│", "─", "│" }, -- redondeado
        layout_config = {
          prompt_position = "bottom",
        },
        sorting_strategy = "ascending",
      },
    },
  },
}

M.nvdash = { load_on_startup = true }
M.ui = {
  tabufline = {
    lazyload = false,
  },
  statusline = {
    theme = "default",
    separator_style = "round",
  },
}

return M
