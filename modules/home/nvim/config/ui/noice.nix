{
  plugins.noice = {
    enable = true;
    settings = {
      lsp = {
        override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
      };
      routes = [
        {
          filter = {
            event = "msg_show";
            any = [
              { find = "%d+L, %d+B"; }
              { find = "; after #%d+"; }
              { find = "; before #%d+"; }
            ];
          };
          view = "mini";
        }
      ];
      presets = {
        bottom_search = true;
        command_palette = true;
        long_message_to_split = true;
      };
    };
  };

  keymaps = [
    { key = "<leader>sn"; mode = [ "n" ]; action = ""; options.desc = "+noice"; }
    { key = "<S-Enter>"; mode = [ "c" ]; action = "<cmd>lua require('noice').redirect(vim.fn.getcmdline())<cr>"; options.desc = "Redirect Cmdline"; }
    { key = "<leader>snl"; mode = [ "n" ]; action = "<cmd>lua require('noice').cmd('last')<cr>"; options.desc = "Noice Last Message"; }
    { key = "<leader>snh"; mode = [ "n" ]; action = "<cmd>lua require('noice').cmd('history')<cr>"; options.desc = "Noice History"; }
    { key = "<leader>sna"; mode = [ "n" ]; action = "<cmd>lua require('noice').cmd('all')<cr>"; options.desc = "Noice All"; }
    { key = "<leader>snd"; mode = [ "n" ]; action = "<cmd>lua require('noice').cmd('dismiss')<cr>"; options.desc = "Dismiss All"; }
    { key = "<leader>snt"; mode = [ "n" ]; action = "<cmd>lua require('noice').cmd('pick')<cr>"; options.desc = "Noice Picker (Telescope/FzfLua)"; }
    { key = "<c-f>"; mode = [ "i" "n" "s" ]; action.__raw = "function() if not require('noice.lsp').scroll(4) then return '<c-f>' end end"; options = { silent = true; expr = true; desc = "Scroll Forward"; }; }
    { key = "<c-b>"; mode = [ "i" "n" "s" ]; action.__raw = "function() if not require('noice.lsp').scroll(-4) then return '<c-b>' end end"; options = { silent = true; expr = true; desc = "Scroll Backward"; }; }
  ];

  extraConfigLua = ''
    if vim.o.filetype == "lazy" then
      vim.cmd([[messages clear]])
    end
  '';
}
