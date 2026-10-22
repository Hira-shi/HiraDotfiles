return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "luadoc", "vimdoc", "printf",
        "c", "cpp", "cmake", "make",
        "python", "rust", "java",
        "bash", "json", "markdown", "markdown_inline", "dot",
      },
    },
  },
}
