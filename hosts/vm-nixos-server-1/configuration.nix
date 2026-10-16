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
        nodeIp = "10.0.30.20";
        useCommonVmNodeNetworking = true;
        vlan20MacAddress = "98:b1:c7:e9:32:20";
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
