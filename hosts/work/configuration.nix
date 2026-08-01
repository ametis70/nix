{ pkgs, host, ... }:

{
  nix.enable = false;
  nix.package = pkgs.nix;
  users.users.${host.username}.home = "/Users/${host.username}";
  system.primaryUser = host.username;

  custom = {
    macosDefaults.enable = true;
    homebrewBundle.enable = true;
    appLauncher.enable = true;
    touchIdSudo.enable = true;
  };

  system.stateVersion = 5;
}
