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
      vlanMac = "62:d9:31:bd:67:20";
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
