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
    intelGraphics.enable = true;
    swapfile.enable = true;

    # This host tags VLAN 20 itself (native VLAN 30 on enp1s0).
    vlanClient = {
      enable = true;
      interface = "enp1s0";
      vlanMac = "00:e0:4c:74:51:20";
      createVlanNetdev = true;
    };

    wakeOnLan = {
      enable = true;
      interface = "enp1s0";
    };

    k3s = {
      enable = true;
      init = true;
      interface = "enp1s0"; # Use physical interface for VLAN 30 (native)
    };

    nut = {
      enable = true;
      role = "server";
    };

    nfs.enable = true;
  };

  system.stateVersion = "24.11";
}
