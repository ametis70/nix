{ specialArgs, ... }:
{
  home.homeDirectory = "/home/${specialArgs.host.username}";
  home.stateVersion = specialArgs.version;
}
