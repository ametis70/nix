{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  xdg = {
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = lib.mkDefault [
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  environment.systemPackages = with pkgs; [ kdePackages.polkit-kde-agent-1 ];

  security.pam.services.greetd.enableGnomeKeyring = true;
  security.polkit.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.xserver.exportConfiguration = true;
}
