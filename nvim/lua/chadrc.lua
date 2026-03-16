---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "chadracula",
}

M.mason = {
  pkgs = {
    -- LSP servers
    "html-lsp",
    "css-lsp",
    "typescript-language-server",
    "tailwindcss-language-server",
    "eslint-lsp",
    -- Formatters
    "prettier",
    "stylua",
  },
}

return M
