{ lib, config, ... }:

let
  cfg = config.custom.openssh;
in
{
  options.custom.openssh.enable = lib.mkEnableOption "OpenSSH server (key-only auth)" // {
    default = true;
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
