{
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
}
