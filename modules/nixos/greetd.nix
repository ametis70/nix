{
  pkgs,
  lib,
  specialArgs,
  ...
}:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd Hyprland";
        user = specialArgs.host.username;
      };
    };
  };
}
