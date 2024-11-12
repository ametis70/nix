{
  pkgs,
  inputs,
  specialArgs,
  ...
}:

{
  imports = [ inputs.nixos-raspberrypi.lib.inject-overlays ];

  time.timeZone = "America/Argentina/Buenos_Aires";

  system.copySystemConfiguration = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking = {
    hostName = specialArgs.host.hostname;
    networkmanager.enable = true;
  };

  nix.settings.trusted-users = [ "${specialArgs.host.username}" ];

  environment.systemPackages = with pkgs; [
    neovim
    curl
    git
  ];

  services.openssh.enable = true;

  users = {
    users = {
      root.initialPassword = "root";
      "${specialArgs.host.username}" = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };

  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  system.stateVersion = specialArgs.version;
}
