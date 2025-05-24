{ pkgs, lib, ... }:

{
  services.gpg-agent = {
    enable = true;
    enableScDaemon = false;
    enableZshIntegration = lib.mkDefault false;
    enableSshSupport = false;
    pinentryPackage = lib.mkDefault pkgs.pinentry-gnome3;
  };
}
