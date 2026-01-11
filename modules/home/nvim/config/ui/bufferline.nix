{
  plugins.bufferline = {
    enable = true;
    settings = {
      options = {
        close_command.__raw = "function(n) Snacks.bufdelete(n) end";
        right_mouse_command.__raw = "function(n) Snacks.bufdelete(n) end";
        diagnostics = "nvim_lsp";
        always_show_bufferline = false;
        diagnostics_indicator.__raw = ''
          function(_, _, diag)
            local icons = Nix.icons.diagnostics
            local ret = (diag.error and icons.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.Warn .. diag.warning or "")
            return vim.trim(ret)
          end
        '';
        offsets = [
          {
            filetype = "neo-tree";
            text = "Neo-tree";
            highlight = "Directory";
            text_align = "left";
          }
          {
            filetype = "snacks_layout_box";
          }
        ];
        get_element_icon.__raw = ''
          function(opts)
            return Nix.icons.ft[opts.filetype]
          end
        '';
      };
    };
  };

  keymaps = [
    { key = "<leader>bp"; mode = [ "n" ]; action = "<Cmd>BufferLineTogglePin<CR>"; options.desc = "Toggle Pin"; }
    { key = "<leader>bP"; mode = [ "n" ]; action = "<Cmd>BufferLineGroupClose ungrouped<CR>"; options.desc = "Delete Non-Pinned Buffers"; }
    { key = "<leader>br"; mode = [ "n" ]; action = "<Cmd>BufferLineCloseRight<CR>"; options.desc = "Delete Buffers to the Right"; }
    { key = "<leader>bl"; mode = [ "n" ]; action = "<Cmd>BufferLineCloseLeft<CR>"; options.desc = "Delete Buffers to the Left"; }
    { key = "<S-h>"; mode = [ "n" ]; action = "<cmd>BufferLineCyclePrev<cr>"; options.desc = "Prev Buffer"; }
    { key = "<S-l>"; mode = [ "n" ]; action = "<cmd>BufferLineCycleNext<cr>"; options.desc = "Next Buffer"; }
    { key = "[b"; mode = [ "n" ]; action = "<cmd>BufferLineCyclePrev<cr>"; options.desc = "Prev Buffer"; }
    { key = "]b"; mode = [ "n" ]; action = "<cmd>BufferLineCycleNext<cr>"; options.desc = "Next Buffer"; }
    { key = "[B"; mode = [ "n" ]; action = "<cmd>BufferLineMovePrev<cr>"; options.desc = "Move buffer prev"; }
    { key = "]B"; mode = [ "n" ]; action = "<cmd>BufferLineMoveNext<cr>"; options.desc = "Move buffer next"; }
  ];

  extraConfigLua = ''
    vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
      callback = function()
        vim.schedule(function()
          pcall(nvim_bufferline)
        end)
      end,
    })
  '';
}
