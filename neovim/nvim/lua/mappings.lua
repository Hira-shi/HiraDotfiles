require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- buffers ouverts, comme dans LazyVim
map("n", "<S-h>", function()
  require("nvchad.tabufline").prev()
end, { desc = "buffer goto prev" })
map("n", "<S-l>", function()
  require("nvchad.tabufline").next()
end, { desc = "buffer goto next" })

-- <leader>ch (LazyVim) is NvCheatsheet in NvChad, so source/header lives on <A-o>
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "clangd" then
      map("n", "<A-o>", "<cmd>LspClangdSwitchSourceHeader<cr>", {
        buffer = args.buf,
        desc = "LSP switch source/header (C/C++)",
      })
    end
  end,
})
