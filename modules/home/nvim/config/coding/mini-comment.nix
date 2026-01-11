{
  plugins.ts-context-commentstring = {
    enable = true;
    settings = {
      enable_autocmd = false;
    };
  };

  plugins.mini-comment = {
    enable = true;
    settings = {
      options = {
        custom_commentstring.__raw = ''
          function()
            return require("ts_context_commentstring.internal").calculate_commentstring()
              or vim.bo.commentstring
          end
        '';
      };
    };
  };
}
