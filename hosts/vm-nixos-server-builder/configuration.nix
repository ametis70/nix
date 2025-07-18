{
  specialArgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/docker.nix
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
    firewall.enable = false;
  };

  system.stateVersion = "25.05";
}
