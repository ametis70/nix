{ lib, config, ... }:

let
  cfg = config.custom.services.openssh;
in
{
  options.custom.services.openssh = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable OpenSSH service";
    };
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
