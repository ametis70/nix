{ lib, config, ... }:

let
  cfg = config.custom.touchIdSudo;
in
{
  options.custom.touchIdSudo.enable = lib.mkEnableOption "Touch ID authentication for sudo";

  config = lib.mkIf cfg.enable {
    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
