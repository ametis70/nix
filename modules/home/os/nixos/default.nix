{ lib, host, ... }:
let
  isNixOS = (host.system == "x86_64-linux" || host.system == "aarch64-linux") && host.nixos;
in
{
  config = lib.mkIf isNixOS {
    home.homeDirectory = "/home/${host.username}";
  };
}
