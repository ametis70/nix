{ specialArgs, ... }:

with specialArgs; {

  imports = [ ../common.nix ];

  home.username = host.username;
  home.homeDirectory = "/Users/${host.username}";
}
