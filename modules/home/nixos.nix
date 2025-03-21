{ specialArgs, ... }:

{
  imports = [ ./common.nix ];

  home.homeDirectory = "/home/${specialArgs.host.username}";
}
