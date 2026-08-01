{ lib, config, ... }:

let
  cfg = config.custom.homebrewBundle;
in
{
  options.custom.homebrewBundle.enable = lib.mkEnableOption "Homebrew bundle (taps, brews, casks, Mac App Store apps)";

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = true;
        cleanup = "zap";
      };
      taps = [
        "d12frosted/emacs-plus"
      ];
      brews = [
        "gettext"
        "choose-gui"
        "colima"
        "openssl"
        "asdf"
        "emacs-plus@30"
      ];
      casks = [
        "gimp"
        "inkscape"
        "jordanbaird-ice"
        "alt-tab"
        "redquits"
        "kitty"
        "moonlight"
        "cursor"
        "windsurf"
      ];
      masApps = {
        WireGuard = 1441195209;
      };
    };
  };
}
