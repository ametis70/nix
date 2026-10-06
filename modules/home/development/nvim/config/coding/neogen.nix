{
  plugins.neogen = {
    enable = true;
    settings = {
      snippet_engine = "mini";
    };
  };

  keymaps = [
    {
      key = "<leader>cn";
      mode = [ "n" ];
      action = "<cmd>lua require('neogen').generate()<cr>";
      options.desc = "Generate Annotations (Neogen)";
    }
  ];
}
