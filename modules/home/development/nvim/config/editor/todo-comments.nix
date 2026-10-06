{
  plugins.todo-comments = {
    enable = true;
    settings = { };
  };

  keymaps = [
    {
      key = "]t";
      mode = [ "n" ];
      action = "<cmd>lua require('todo-comments').jump_next()<cr>";
      options.desc = "Next Todo Comment";
    }
    {
      key = "[t";
      mode = [ "n" ];
      action = "<cmd>lua require('todo-comments').jump_prev()<cr>";
      options.desc = "Previous Todo Comment";
    }
    {
      key = "<leader>xt";
      mode = [ "n" ];
      action = "<cmd>Trouble todo toggle<cr>";
      options.desc = "Todo (Trouble)";
    }
    {
      key = "<leader>xT";
      mode = [ "n" ];
      action = "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>";
      options.desc = "Todo/Fix/Fixme (Trouble)";
    }
    {
      key = "<leader>st";
      mode = [ "n" ];
      action = "<cmd>TodoTelescope<cr>";
      options.desc = "Todo";
    }
    {
      key = "<leader>sT";
      mode = [ "n" ];
      action = "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>";
      options.desc = "Todo/Fix/Fixme";
    }
  ];
}
