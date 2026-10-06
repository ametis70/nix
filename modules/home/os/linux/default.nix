{
  pkgs,
  lib,
  host,
  ...
}:
let
  isLinux = (host.system == "x86_64-linux" || host.system == "aarch64-linux") && !host.nixos;
in
{
  config = lib.mkIf isLinux {
    home.homeDirectory = "/home/${host.username}";

    home.packages = with pkgs; [
      pinentry-curses
      xclip
      wl-clipboard
    ];
  };
}
