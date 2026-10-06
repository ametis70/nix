{
  plugins.treesj = {
    enable = true;
    autoLoad = true;
  };

  keymaps = [
    {
      key = "<leader>ctt";
      mode = [ "n" ];
      action = "<cmd>TSJToggle<CR>";
      options.desc = "Toggle split/join";
    }
    {
      key = "<leader>cts";
      mode = [ "n" ];
      action = "<cmd>TSJSplit<CR>";
      options.desc = "Split node";
    }
    {
      key = "<leader>ctj";
      mode = [ "n" ];
      action = "<cmd>TSJJoin<CR>";
      options.desc = "Join node";
    }
  ];
}
