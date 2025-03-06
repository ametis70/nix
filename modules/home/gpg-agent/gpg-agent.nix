{ pkgs, lib, ... }:

{
  services.gpg-agent = {
    enable = true;
    enableScDaemon = false;
    enableZshIntegration = false;
    pinentryPackage = lib.mkDefault pkgs.pinentry-gnome3;
  };
}
