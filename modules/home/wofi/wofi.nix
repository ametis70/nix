{ pkgs, ... }:

let
  wrapped = pkgs.writeShellScriptBin "wofi" ''
    flock --nonblock /tmp/.wofi.lock ${pkgs.wofi}/bin/wofi "$@"
  '';

  wofi-wrapped = pkgs.symlinkJoin {
    name = "wofi";
    paths = [
      wrapped
      pkgs.wofi
    ];
  };
in

{
  programs.wofi = {
    enable = true;
    package = wofi-wrapped;
    settings = {
      hide_scroll = true;
      key_expand = "Tab";
      key_backward = "Ctrl-p";
      key_forward = "Ctrl-n";
      key_pgup="Ctrl-u";
      key_pgdn="Ctrl-d";
    };
  };
  xdg.configFile."wofi/style.css".source = ./style.css;
}
