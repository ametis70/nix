{
  plugins.smear-cursor = {
    enable = true;
    settings = {
      enabled = false;
      hide_target_hack = false;
      cursor_color = "Cursor";
      cursor_color_insert_mode = "Cursor";
      max_length = 40;
      max_length_insert_mode = 4;
      trailing_stiffness = 0.3;
      trailing_stiffness_insert_mode = 0.35;
      distance_stop_animating = 0.05;
    };
  };

  extraConfigLua = ''
    Snacks.toggle({
      name = "Smear Cursor",
      get = function()
        return require("smear_cursor").enabled
      end,
      set = function(state)
        require("smear_cursor").enabled = state
      end,
    }):map("<leader>uM")
  '';

}
