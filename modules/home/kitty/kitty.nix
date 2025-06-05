{
  pkgs,
  lib,
  host,
  ...
}:

let
  nixgl = import ../../../utils/nixgl.nix {
    inherit pkgs lib;
  };
in
{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    package =
      if (host.system == "x86_64-linux" && !host.nixos) then
        (nixgl.wrapMesa pkgs.kitty)
      else if (host.system == "x86_64-linux" && host.nixos) then
        pkgs.kitty
      else
        null;
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    font = {
      size = lib.mkDefault 14;
      name = "family=Iosevka";
    };
    keybindings = {
      "kitty_mod+w" = "close_window_with_confirmation";

    };
    settings = {
      confirm_os_window_close = -1;
      scrollback_lines = 10000;
      update_check_interval = 0;
      window_padding_width = 12;
      symbol_map = "U+e000-U+e00a,U+ea60-U+ebeb,U+e0a0-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b1,U+e700-U+e7c5,U+ed00-U+efc1,U+f000-U+f2ff,U+f000-U+f2e0,U+f300-U+f372,U+f400-U+f533,U+f0001-U+f1af0 Hack Nerd Font Mono";
    };
  };
}
