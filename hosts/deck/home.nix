{ specialArgs, ... }:

with specialArgs; {

  imports = [ ../common.nix ];

  home.username = host.username;
  home.homeDirectory = "/home/${host.username}";
}
