{ lib, config, ... }:

let
  cfg = config.custom.services.openssh;
in
{
  options.custom.services.openssh = {
    enable = lib.mkEnableOption "Enable OpenSSH service";
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
