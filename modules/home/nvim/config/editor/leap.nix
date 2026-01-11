{ lib, ... }:
{
  plugins.flit = {
    enable = true;
    settings = {
      labeled_modes = "nx";
    };
  };

  plugins.leap = {
    enable = true;
    settings = { };
  };

  plugins.mini-surround.settings.mappings = lib.mkForce {
    add = "gza";
    delete = "gzd";
    find = "gzf";
    find_left = "gzF";
    highlight = "gzh";
    replace = "gzr";
    update_n_lines = "gzn";
  };

  extraPlugins = [ ];

  keymaps = [
    {
      key = "s";
      mode = [ "n" "x" "o" ];
      action = "<cmd>lua require('leap').leap{target_windows={vim.fn.win_getid()}}<cr>";
      options.desc = "Leap Forward to";
    }
    {
      key = "S";
      mode = [ "n" "x" "o" ];
      action = "<cmd>lua require('leap').leap{target_windows={vim.fn.win_getid()}, backward=true}<cr>";
      options.desc = "Leap Backward to";
    }
    {
      key = "gs";
      mode = [ "n" "x" "o" ];
      action = "<cmd>lua require('leap').leap{target_windows=vim.api.nvim_tabpage_list_wins(0)}<cr>";
      options.desc = "Leap from Windows";
    }
    {
      key = "gz";
      mode = [ "n" "x" ];
      action = "";
      options.desc = "+surround";
    }
  ];

  extraConfigLua = ''
    pcall(vim.keymap.del, { "x", "o" }, "x")
    pcall(vim.keymap.del, { "x", "o" }, "X")
  '';
}
