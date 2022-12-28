local nmap = require('util').nmap

require("nvim-tree").setup {
  disable_netrw = true,
  hijack_netrw = true,
  view = {
    number = true,
    relativenumber = true,
    mappings = {
      list = {
        {
          key = "C",
          action = "cd",
          mode = "n",
        },
      },
    },
  },
  filters = {
    dotfiles = true,
    custom = { ".git" },
  },
}

nmap("X", "<cmd>NvimTreeToggle<cr>", {silent=true})
nmap("<Leader>tm", "<cmd>h nvim-tree-default-mappings<cr>", {silent=true})
