{
  plugins.treesj = {
    enable = true;
    autoLoad = true;
  };

  keymaps = [
    {
      key = "<leader>m";
      mode = [ "n" ];
      action = "<cmd>TSJToggle<CR>";
      options.desc = "Toggle split/join";
    }
    {
      key = "<leader>s";
      mode = [ "n" ];
      action = "<cmd>TSJSplit<CR>";
      options.desc = "Split node";
    }
    {
      key = "<leader>j";
      mode = [ "n" ];
      action = "<cmd>TSJJoin<CR>";
      options.desc = "Join node";
    }
  ];
}
