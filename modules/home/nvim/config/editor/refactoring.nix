{
  plugins.refactoring = {
    enable = true;
    settings = {
      prompt_func_return_type = {
        go = false;
        java = false;
        cpp = false;
        c = false;
        h = false;
        hpp = false;
        cxx = false;
      };
      prompt_func_param_type = {
        go = false;
        java = false;
        cpp = false;
        c = false;
        h = false;
        hpp = false;
        cxx = false;
      };
      printf_statements = { };
      print_var_statements = { };
      show_success_message = true;
    };
  };

  keymaps = [
    {
      key = "<leader>r";
      mode = [ "n" "x" ];
      action = "";
      options.desc = "+refactor";
    }
    {
      key = "<leader>rs";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').select_refactor()<cr>";
      options.desc = "Refactor";
    }
    {
      key = "<leader>ri";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').refactor('Inline Variable')<cr>";
      options.desc = "Inline Variable";
    }
    {
      key = "<leader>rb";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').refactor('Extract Block')<cr>";
      options.desc = "Extract Block";
    }
    {
      key = "<leader>rf";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').refactor('Extract Block To File')<cr>";
      options.desc = "Extract Block To File";
    }
    {
      key = "<leader>rP";
      mode = [ "n" ];
      action = "<cmd>lua require('refactoring').debug.printf({ below = false })<cr>";
      options.desc = "Debug Print";
    }
    {
      key = "<leader>rp";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').debug.print_var({ normal = true })<cr>";
      options.desc = "Debug Print Variable";
    }
    {
      key = "<leader>rc";
      mode = [ "n" ];
      action = "<cmd>lua require('refactoring').debug.cleanup({})<cr>";
      options.desc = "Debug Cleanup";
    }
    {
      key = "<leader>rF";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').refactor('Extract Function To File')<cr>";
      options.desc = "Extract Function To File";
    }
    {
      key = "<leader>rx";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').refactor('Extract Variable')<cr>";
      options.desc = "Extract Variable";
    }
    {
      key = "<leader>rf";
      mode = [ "n" "x" ];
      action = "<cmd>lua require('refactoring').refactor('Extract Function')<cr>";
      options.desc = "Extract Function";
    }
  ];
}
