{
  plugins.treesitter-context = {
    enable = true;
    settings = {
      mode = "cursor";
      max_lines = 3;
    };
  };

  extraConfigLua = ''
    local tsc = require("treesitter-context")
    Snacks.toggle({
      name = "Treesitter Context",
      get = tsc.enabled,
      set = function(state)
        if state then
          tsc.enable()
        else
          tsc.disable()
        end
      end,
    }):map("<leader>ut")
  '';
}
