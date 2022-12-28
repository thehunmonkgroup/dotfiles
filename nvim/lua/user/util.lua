local _M = {}

function _M.map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function _M.nmap(lhs, rhs, opts)
  _M.map("n", lhs, rhs, opts)
end

return _M
