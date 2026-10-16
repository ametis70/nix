{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.desktop.de.plasma;
in
{
  options.custom.desktop.de.plasma = {
    enable = lib.mkEnableOption "Enable Plasma DE";
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    services.displayManager = {
      defaultSession = lib.mkDefault "plasma";
    };
    custom.desktop.keyring.kwallet.enable = lib.mkDefault true;
    custom.desktop.dm.sddm.enable = lib.mkDefault true;
    environment.systemPackages = with pkgs; [
      pinentry-qt
    ];
  };
}
