{ lib, config, ... }:

let
  cfg = config.custom.gnome-keyring;
in
{
  options.custom.gnome-keyring.enable = lib.mkEnableOption "gnome-keyring (secrets + ssh agent)";

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
