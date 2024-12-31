{
  pkgs,
  lib,
  ...
}:

{
  programs.hyprland.enable = true;

  xdg = {
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = lib.mkDefault [
        pkgs.xdg-desktop-portal-hyprland
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
