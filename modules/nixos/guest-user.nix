{
  lib,
  pkgs,
  config,
  ...
}:

{
  environment.shells = [ pkgs.bash ];

  users.users.guest = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.bash;
  };

  hardware.pulseaudio.enable = false;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    vscodium
    chromium
  ];

  # Remove extra gtk portal if hyprland is enabled
  xdg.portal.extraPortals = lib.optionals config.programs.hyprland.enable lib.mkForce [
    pkgs.xdg-desktop-portal-hyprland
  ];
}
