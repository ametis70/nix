{
  pkgs,
  inputs,
  specialArgs,
  ...
}:

{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix
    ../../modules/nixos/docker.nix

    "${inputs.argononed}/OS/nixos"
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
    firewall.enable = false;
  };

  users.users.root.initialPassword = "root";

  raspberry-pi-nix.board = "bcm2711";
  hardware.raspberry-pi.i2c.enable = true;
  hardware.deviceTree.filter = "bcm2711-rpi-*.dtb";

  boot.loader = {
    systemd-boot.enable = false;
  };

  virtualisation.docker.daemon.settings = {
    live-restore = false; # Required for docker swarm
  };

  environment.systemPackages = with pkgs; [
    nfs-utils
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/nfs               755 0    0"
    "d /mnt/nfs/docker/config 755 1000 100"
    "d /mnt/nfs/docker/data   755 1000 100"
  ];

  fileSystems = {
    "/mnt/nfs/docker/config" = {
      device = "nas.lan:/export/docker/config";
      fsType = "nfs";
    };

    "/mnt/nfs/docker/data" = {
      device = "nas.lan:/export/docker/data";
      fsType = "nfs";
    };
  };

  # Argon ONE V2 case
  # FIXME: The argonone overlay for argononed is not working and the settings are not being picked up

  disabledModules = [ "services/hardware/argonone.nix" ];

  hardware.raspberry-pi.config = {
    all = {
      dt-overlays = {
        argonone = {
          enable = true;
          params = { };
        };
      };
    };
  };

  services.argonone = {
    enable = true;
    logLevel = 4;
    settings = {
      fanTemp0 = 36;
      fanSpeed0 = 10;
      fanTemp1 = 41;
      fanSpeed1 = 50;
      fanTemp2 = 46;
      fanSpeed2 = 80;
      hysteresis = 4;
    };
  };

  system.stateVersion = "24.11";
}
