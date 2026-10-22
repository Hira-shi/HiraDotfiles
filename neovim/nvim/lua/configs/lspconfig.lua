require("nvchad.configs.lspconfig").defaults()

-- servers are installed with :MasonInstallAll
local servers = { "clangd", "neocmake", "pyright", "rust_analyzer", "jdtls" }

-- ported from the LazyVim config (lua/config/options.lua)
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
    "--std=c++20",
  },
  root_markers = {
    "Makefile",
    "configure.ac",
    "configure.in",
    "config.h.in",
    "compile_commands.json",
    "compile_flags.txt",
    ".git",
  },
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
})

vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
