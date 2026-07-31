{ lib, config, pkgs, ... }:

let
  cfg = config.custom.wofi;

  writeSingleInstanceWrapper =
    pkg: name:
    pkgs.writeShellScriptBin "${name}" ''
      [ $(pgrep -c 'wofi') -eq 1 ] && exec ${pkg}/bin/${name} "$@"
    '';

  joinSingleInstanceWrapper =
    pkg: name:
    pkgs.symlinkJoin {
      name = name;
      paths = [
        (writeSingleInstanceWrapper pkg name)
        pkg
      ];
    };

  wofi-wrapped = (joinSingleInstanceWrapper pkgs.wofi "wofi");
  wofi-pass-wrapped = (joinSingleInstanceWrapper pkgs.wofi-pass "wofi-pass");
  wofi-emoji-wrapped = (joinSingleInstanceWrapper pkgs.wofi-emoji "wofi-emoji");
in
{
  options.custom.wofi.enable = lib.mkEnableOption "wofi launcher (single-instance wrappers)";

  config = lib.mkIf cfg.enable {
    programs.wofi = {
      enable = true;
      package = wofi-wrapped;
      settings = {
        hide_scroll = true;
        key_expand = "Tab";
        key_backward = "Ctrl-p";
        key_forward = "Ctrl-n";
        key_pgup = "Ctrl-u";
        key_pgdn = "Ctrl-d";
        matching = "multi-contains";
      };
    };

    home.packages = with pkgs; [
      wofi-pass-wrapped
      wofi-emoji-wrapped
      wtype
      wl-clipboard
    ];

    xdg.configFile."wofi/style.css".source = ./style.css;
  };
}
