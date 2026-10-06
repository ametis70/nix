{
  plugins.lsp.servers.tailwindcss = {
    enable = true;
    extraOptions = {
      filetypes_exclude = [ "markdown" ];
      filetypes_include = [ ];
      filetypes.__raw = ''
        (function()
          local filetypes = vim.lsp.config.tailwindcss.filetypes or {}
          local exclude = { "markdown" }
          filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(exclude, ft)
          end, filetypes)
          return filetypes
        end)()
      '';
      settings = {
        tailwindCSS = {
          includeLanguages = {
            elixir = "html-eex";
            eelixir = "html-eex";
            heex = "html-eex";
          };
        };
      };
    };
  };
}
