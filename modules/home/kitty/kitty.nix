{ pkgs, host, ... }:

let
  themeSettings =
    if (host.version == "unstable") then
      { themeFile = "tokyo_night_storm"; }
    else
      { theme = "Tokyo Night Storm"; };
in

{
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    font = {
      size = 14;
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
  } // themeSettings;
}
