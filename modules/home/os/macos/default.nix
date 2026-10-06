{
  pkgs,
  lib,
  host,
  ...
}:
let
  isDarwin = host.system == "aarch64-darwin";
in
{
  config = lib.mkIf isDarwin {
    home.homeDirectory = "/Users/${host.username}";

    home.packages = with pkgs; [
      pinentry_mac
      pngpaste
    ];
  };
}
