{
  plugins.mini-diff = {
    enable = true;
    settings = {
      view = {
        style = "sign";
        signs = {
          add = "▎";
          change = "▎";
          delete = "";
        };
      };
    };
  };

  keymaps = [
    {
      key = "<leader>go";
      mode = [ "n" ];
      action = "<cmd>lua require('mini.diff').toggle_overlay(0)<cr>";
      options.desc = "Toggle mini.diff overlay";
    }
  ];

  extraConfigLua = ''
    Snacks.toggle({
      name = "Mini Diff Signs",
      get = function()
        return vim.g.minidiff_disable ~= true
      end,
      set = function(state)
        vim.g.minidiff_disable = not state
        if state then
          require("mini.diff").enable(0)
        else
          require("mini.diff").disable(0)
        end
        vim.defer_fn(function()
          vim.cmd([[redraw!]])
        end, 200)
      end,
    }):map("<leader>uG")
  '';
}
