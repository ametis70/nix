{
  pkgs,
  lib,
  config,
  hyprland,
  host,
  ...
}:

let
  cfg = config.custom.desktop.wm.hyprland;
  hyprlandPackages = hyprland.${host.channel}.packages.${pkgs.stdenv.hostPlatform.system};
in

{
  options.custom.desktop.wm.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland WM";
  };

  config = lib.mkIf cfg.enable {
    programs.uwsm.enable = true;
    security.polkit.enable = true;
    services.dbus.enable = true;

    programs.hyprland = {
      enable = true;
      package = hyprlandPackages.hyprland;
      portalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;
      withUWSM = true;
    };

    xdg = {
      portal = {
        enable = true;
        config.common.default = [
          "hyprland"
          "gtk"
        ];
        extraPortals = lib.mkDefault [
          hyprlandPackages.xdg-desktop-portal-hyprland
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };

    environment.systemPackages = with pkgs; [ kdePackages.polkit-kde-agent-1 ];

    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    services.xserver.exportConfiguration = true;
  };
}
