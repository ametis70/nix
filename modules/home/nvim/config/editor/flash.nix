{
  plugins.flash = {
    enable = true;
    settings = { };
  };

  keymaps = [
    {
      key = "s";
      mode = [ "n" "x" "o" ];
      action = "<cmd>lua require('flash').jump()<cr>";
      options.desc = "Flash";
    }
    {
      key = "S";
      mode = [ "n" "o" "x" ];
      action = "<cmd>lua require('flash').treesitter()<cr>";
      options.desc = "Flash Treesitter";
    }
    {
      key = "r";
      mode = [ "o" ];
      action = "<cmd>lua require('flash').remote()<cr>";
      options.desc = "Remote Flash";
    }
    {
      key = "R";
      mode = [ "o" "x" ];
      action = "<cmd>lua require('flash').treesitter_search()<cr>";
      options.desc = "Treesitter Search";
    }
    {
      key = "<c-s>";
      mode = [ "c" ];
      action = "<cmd>lua require('flash').toggle()<cr>";
      options.desc = "Toggle Flash Search";
    }
    {
      key = "<c-space>";
      mode = [ "n" "o" "x" ];
      action.__raw = ''
        function()
          require("flash").treesitter({
            actions = {
              ["<c-space>"] = "next",
              ["<BS>"] = "prev",
            },
          })
        end
      '';
      options.desc = "Treesitter Incremental Selection";
    }
  ];
}
