{ host, ... }:
{
  imports = [
    ./colorscheme
    ./desktop
    ./development
    ./gaming
    ./homelab
    ./hypervisor
    ./os
    ./programs
    ./shell
  ];

  config = {
    home.username = host.username;
    programs = {
      home-manager.enable = true;
    };
  };
}
