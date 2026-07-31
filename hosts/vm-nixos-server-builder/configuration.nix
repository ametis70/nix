{
  specialArgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/nixos/docker.nix
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
    firewall.enable = false;
  };

  custom = {
    nut = {
      enable = true;
      delay = 1;
      isVm = true;
      role = "client";
    };
  };

  system.stateVersion = "25.05";
}
