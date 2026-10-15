{ lib, config, ... }:

let
  cfg = config.custom.desktop.keyring.gnome-keyring;
in
{
  options.custom.desktop.keyring.gnome-keyring = {
    enable = lib.mkEnableOption "Enable gnome-keyring service";
  };

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = config.services.greetd.enable;
    security.pam.services.sshd.enableGnomeKeyring = true;
  };
}
