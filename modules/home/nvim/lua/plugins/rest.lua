local init = function()
  local wk = require("which-key")

  local augroup = vim.api.nvim_create_augroup("RestNvim", {})
  vim.api.nvim_clear_autocmds({ group = augroup })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = { "*.http" },
    callback = function(ev)
      vim.bo[ev.buf].filetype = "http"

      wk.add({
        {
          buffer = ev.buf,
          mode = { "n" },
          { "<localleader>r", "<cmd>Rest run<cr>",      desc = "Run the request under the cursor" },
          { "<localleader>l", "<cmd>Rest run last<cr>", desc = "Re-run the last request" },
        },
      })
    end,
  })
end

return {
  "rest-nvim/rest.nvim",
  init = init,
  event = "BufEnter *.http",
  dependencies = {
    "j-hui/fidget.nvim",
  },
}
