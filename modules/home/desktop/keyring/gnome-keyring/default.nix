{ config, lib, ... }:

let
  cfg = config.custom.desktop.keyring.gnome-keyring;
in
{
  options.custom.desktop.keyring.gnome-keyring = {
    enable = lib.mkEnableOption "Enable gnome-keyring service";
  };

  config = lib.mkIf cfg.enable {
    services.gnome-keyring = {
      enable = true;
      components = [
        "secrets"
        "ssh"
      ];
    };
  };
}
