{ pkgs, host, ... }:

{
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_storm";
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    font = {
      size = 18;
      package = pkgs.iosevka;
      name = "Iosevka Medium";
    };
    keybindings = {
      "kitty_mod+w" = "close_window_with_confirmation";
    };
    settings = {
      confirm_os_window_close = -1;
      scrollback_lines = 10000;
      update_check_interval = 0;
      window_padding_width = 12;
    };
  };
}
