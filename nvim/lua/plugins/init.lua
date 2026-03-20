return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Seamless navigation between vim splits and tmux panes
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        side = "right",
      },
    },
  },

  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.move",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.splitjoin",
    event = "VeryLazy",
    opts = {},
  },

  {
    "echasnovski/mini.indentscope",
    event = "VeryLazy",
    opts = {},
  },
}
