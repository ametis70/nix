{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.desktop.keyring.kwallet;
in
{
  options.custom.desktop.keyring.kwallet = {
    enable = lib.mkEnableOption "Enable kwallet service";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.login.kwallet.enable = true;
    security.pam.services.kde.kwallet.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.kwalletmanager
      kdePackages.ksshaskpass
    ];

    programs.ssh = {
      startAgent = true;
      askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
      enableAskPassword = true;
    };

    environment = {
      sessionVariables = {
        SSH_ASKPASS_REQUIRE = "prefer";
      };
    };
  };
}
