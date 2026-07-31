{ lib, config, ... }:

let
  cfg = config.custom.keyring;
in
{
  options.custom.keyring.enable = lib.mkEnableOption "GNOME keyring + seahorse (PAM integration)";

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = config.services.greetd.enable;
    security.pam.services.sshd.enableGnomeKeyring = true;
  };
}
