local nmap = require('util').nmap

nmap("<Leader>db", ":lua require('dap').toggle_breakpoint()<CR>", {silent=true})
nmap("<Leader>dB", ":lua require('dap').set_breakpoint()<CR>", {silent=true})
nmap("<Leader>lp", ":lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", {silent=true})
nmap("<Leader>dr", ":lua require('dap').repl.open()<CR>", {silent=true})
nmap("<Leader>dl", ":lua require('dap').run_last()<CR>", {silent=true})
