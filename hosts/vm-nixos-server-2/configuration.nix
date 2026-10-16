{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  custom = {
    networking = {
      networkd.enable = true;
    };

    swap = {
      enable = true;
      sizeGB = 16;
    };

    homelab = {
      k3s.node = {
        enable = true;
        nodeIp = "10.0.30.21";
        useCommonVmNodeNetworking = true;
        vlan20MacAddress = "62:d9:31:bd:67:20";
      };
      nfs.client.enable = true;
      nut = {
        enable = true;
        delay = 1;
        isVm = true;
        role = "client";
      };
    };
  };

  system.stateVersion = "25.05";
}
