{
  pkgs,
  lib,
  host,
  ...
}:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.tuigreet} --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time --cmd 'uwsm start -- hyprland.desktop'";
        user = host.username;
      };
    };
  };
}
