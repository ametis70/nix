{
  plugins.conform-nvim = {
    enable = true;
    settings = {
      default_format_opts = {
        timeout_ms = 3000;
        async = false;
        quiet = false;
        lsp_format = "fallback";
      };
      formatters_by_ft = {
        lua = [ "stylua" ];
        fish = [ "fish_indent" ];
        sh = [ "shfmt" ];
      };
      formatters = {
        injected = {
          options = {
            ignore_errors = true;
          };
        };
      };
    };
  };

  extraConfigLua = ''
    Nix.format.register({
      name = "conform.nvim",
      priority = 100,
      primary = true,
      format = function(buf)
        require("conform").format({ bufnr = buf })
      end,
      sources = function(buf)
        local ret = require("conform").list_formatters(buf)
        return vim.tbl_map(function(v)
          return v.name
        end, ret)
      end,
    })

    Nix.format.setup()
  '';
}
