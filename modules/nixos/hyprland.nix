{
  pkgs,
  lib,
  hyprland,
  host,
  ...
}:

let
  hyprlandPackages = hyprland.${host.channel}.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.hyprland = {
    enable = true;
    package = hyprlandPackages.hyprland;
    portalPackage = hyprlandPackages.xdg-desktop-portal-hyprland;
  };

  xdg = {
    portal = {
      enable = true;
      config.common.default = [
        "gtk"
      ];
      extraPortals = lib.mkDefault [
        hyprlandPackages.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  environment.systemPackages = with pkgs; [ kdePackages.polkit-kde-agent-1 ];
  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver.exportConfiguration = true;
}
