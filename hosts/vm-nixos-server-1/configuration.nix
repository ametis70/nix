{
  pkgs,
  specialArgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix

  ];

  networking.hostName = specialArgs.host.hostname;

  custom = {
    vlanClient = {
      enable = true;
      vlanMac = "98:b1:c7:e9:32:20";
    };

    k3s.enable = true;
    nfs.enable = true;

    nut = {
      enable = true;
      delay = 1;
      isVm = true;
      role = "client";
    };
  };

  system.stateVersion = "25.05";
}
