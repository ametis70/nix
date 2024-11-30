{ pkgs, ... }:

{
  services.gpg-agent = {
    enable = true;
    enableScDaemon = false;
    enableZshIntegration = false;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
