local nmap = require('user.util').nmap

require("dapui").setup()

nmap("<Leader>dx", ":lua require('dapui').toggle()<CR>", {silent=true})
