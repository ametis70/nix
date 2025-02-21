{ pkgs, specialArgs, ... }:

{
  nix.enable = false;
  nix = {
    package = pkgs.nix;
    settings = {
      "extra-experimental-features" = [
        "nix-command"
        "flakes"
      ];
    };
  };

  users.users.${specialArgs.host.username}.home = "/Users/${specialArgs.host.username}";

  homebrew = {
    enable = true;
    casks = [
      "alt-tab"
      "kitty"
    ];
  };

  system.stateVersion = 5;
}
