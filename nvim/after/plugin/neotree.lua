local nmap = require("user.util").nmap

nmap("X", "<cmd>Neotree toggle<cr>", {silent=true})
nmap("<Leader>z", "<cmd>Neotree source=filesystem<cr>", {silent=true})
nmap("<Leader>a", "<cmd>Neotree source=buffers<cr>", {silent=true})

