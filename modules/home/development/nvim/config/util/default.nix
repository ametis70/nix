{ pkgs, ... }:
{
  imports = [
    ./snacks.nix
    ./direnv.nix
    ./persistence.nix
    ./plenary.nix
    ./octo.nix
    ./project.nix
    ./rest.nix
    ./startuptime.nix
  ];
}
