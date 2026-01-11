{
  plugins.which-key = {
    enable = true;
    settings = {
      preset = "helix";
      defaults = { };
      spec = [
        { __unkeyed-1 = "<leader><tab>"; group = "tabs"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>c"; group = "code"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>d"; group = "debug"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>dp"; group = "profiler"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>f"; group = "file/find"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>g"; group = "git"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>gh"; group = "hunks"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>q"; group = "quit/session"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>s"; group = "search"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>u"; group = "ui"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "<leader>x"; group = "diagnostics/quickfix"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "["; group = "prev"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "]"; group = "next"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "g"; group = "goto"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "gs"; group = "surround"; mode = [ "n" "x" ]; }
        { __unkeyed-1 = "z"; group = "fold"; mode = [ "n" "x" ]; }
        {
          __unkeyed-1 = "<leader>b";
          group = "buffer";
          mode = [ "n" "x" ];
          expand.__raw = "function() return require('which-key.extras').expand.buf() end";
        }
        {
          __unkeyed-1 = "<leader>w";
          group = "windows";
          mode = [ "n" "x" ];
          proxy = "<c-w>";
          expand.__raw = "function() return require('which-key.extras').expand.win() end";
        }
        { __unkeyed-1 = "gx"; desc = "Open with system app"; mode = [ "n" "x" ]; }
      ];
    };
  };

  keymaps = [
    {
      key = "<leader>?";
      mode = [ "n" ];
      action = "<cmd>lua require('which-key').show({ global = false })<cr>";
      options.desc = "Buffer Keymaps (which-key)";
    }
    {
      key = "<c-w><space>";
      mode = [ "n" ];
      action = "<cmd>lua require('which-key').show({ keys = '<c-w>', loop = true })<cr>";
      options.desc = "Window Hydra Mode (which-key)";
    }
  ];
}
