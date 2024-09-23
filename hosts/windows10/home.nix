{ pkgs, ... }:

{
  imports = [ ../../modules/home/linux.nix ];

  services = {
    gpg-agent = {
      enable = true;
      enableScDaemon = false;
      enableZshIntegration = false;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };
}
