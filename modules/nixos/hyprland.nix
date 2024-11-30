{
  pkgs,
  lib,
  specialArgs,
  ...
}:

{
  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.greetd.tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd Hyprland";
        user = specialArgs.host.username;
      };
    };
  };

  xdg = {
    portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [
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
