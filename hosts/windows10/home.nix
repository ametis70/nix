{ pkgs, ... }:

{
  imports = [
    ../../modules/home/linux.nix
    ../../modules/home/dev.nix
    ../../modules/home/gpg-agent/gpg-agent.nix
  ];

  services.gpg-agent.pinentryPackage = pkgs.pinentry-curses;

  home.stateVersion = "24.11";
}
