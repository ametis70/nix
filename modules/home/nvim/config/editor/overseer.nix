{
  plugins.overseer = {
    enable = true;
    settings = {
      dap = false;
      task_list = {
        bindings = {
          "<C-h>" = false;
          "<C-j>" = false;
          "<C-k>" = false;
          "<C-l>" = false;
        };
      };
      form = {
        win_opts = { winblend = 0; };
      };
      confirm = {
        win_opts = { winblend = 0; };
      };
      task_win = {
        win_opts = { winblend = 0; };
      };
    };
  };

  plugins.which-key.settings.spec = [
    { __unkeyed-1 = "<leader>o"; group = "overseer"; mode = [ "n" ]; }
  ];

  keymaps = [
    {
      key = "<leader>ow";
      mode = [ "n" ];
      action = "<cmd>OverseerToggle<cr>";
      options.desc = "Task list";
    }
    {
      key = "<leader>oo";
      mode = [ "n" ];
      action = "<cmd>OverseerRun<cr>";
      options.desc = "Run task";
    }
    {
      key = "<leader>oq";
      mode = [ "n" ];
      action = "<cmd>OverseerQuickAction<cr>";
      options.desc = "Action recent task";
    }
    {
      key = "<leader>oi";
      mode = [ "n" ];
      action = "<cmd>OverseerInfo<cr>";
      options.desc = "Overseer Info";
    }
    {
      key = "<leader>ob";
      mode = [ "n" ];
      action = "<cmd>OverseerBuild<cr>";
      options.desc = "Task builder";
    }
    {
      key = "<leader>ot";
      mode = [ "n" ];
      action = "<cmd>OverseerTaskAction<cr>";
      options.desc = "Task action";
    }
    {
      key = "<leader>oc";
      mode = [ "n" ];
      action = "<cmd>OverseerClearCache<cr>";
      options.desc = "Clear cache";
    }
  ];
}
