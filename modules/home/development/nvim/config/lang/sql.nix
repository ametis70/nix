{ lib, pkgs, ... }:
{
  plugins.treesitter.settings.ensure_installed = lib.mkAfter [ "sql" ];

  plugins.vim-dadbod.enable = true;
  plugins.vim-dadbod-completion.enable = true;
  plugins.vim-dadbod-ui.enable = true;

  plugins.blink-cmp.settings.sources = {
    default = lib.mkAfter [ "dadbod" ];
    providers = {
      dadbod = {
        name = "Dadbod";
        module = "vim_dadbod_completion.blink";
      };
    };
  };

  plugins.conform-nvim.settings = {
    formatters = {
      sqlfluff = {
        args = [ "format" "--dialect=ansi" "-" ];
      };
    };
    formatters_by_ft = {
      sql = [ "sqlfluff" ];
      mysql = [ "sqlfluff" ];
      plsql = [ "sqlfluff" ];
    };
  };

  plugins.lint.lintersByFt = {
    sql = [ "sqlfluff" ];
    mysql = [ "sqlfluff" ];
    plsql = [ "sqlfluff" ];
  };

  extraPackages = with pkgs; [
    sqlfluff
  ];

  keymaps = [
    {
      key = "<leader>D";
      mode = [ "n" ];
      action = "<cmd>DBUIToggle<cr>";
      options.desc = "Toggle DBUI";
    }
  ];

  extraConfigLua = ''
    vim.g.omni_sql_default_compl_type = "syntax"
    vim.g.loaded_sql_completion = true

    local data_path = vim.fn.stdpath("data")
    vim.g.db_ui_auto_execute_table_helpers = 1
    vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
    vim.g.db_ui_show_database_icon = true
    vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
    vim.g.db_ui_use_nerd_fonts = true
    vim.g.db_ui_use_nvim_notify = true
    vim.g.db_ui_execute_on_save = false
  '';
}
