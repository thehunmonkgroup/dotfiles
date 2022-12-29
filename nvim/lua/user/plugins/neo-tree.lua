return {
  close_if_last_window = false,
  event_handlers = {
    {
      event = "vim_buffer_enter",
      handler = function ()
        if vim.bo.filetype == "neo-tree" then
          vim.cmd("setlocal number")
        end
      end
    },
  },
}
