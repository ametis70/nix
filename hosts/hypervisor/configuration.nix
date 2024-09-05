{ config, lib, pkgs, specialArgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = false;
      device = "nodev";
      copyKernels = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = specialArgs.host.hostname;
    firewall.enable = false;
    networkmanager.enable = false;
    useDHCP = false;
    enableIPv6 = false;
    bridges = { "br0" = { interfaces = [ "enp39s0" ]; }; };
    interfaces = {
      "br0" = {
        ipv4.addresses = [{
          address = "192.168.10.90";
          prefixLength = 24;
        }];
      };
    };
    defaultGateway = "192.168.10.1";
    nameservers = [ "192.168.10.1" ];
  };

  time.timeZone = "America/Argentina/Buenos_Aires";

  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.users.ametis70 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvjO5PcjSiiAnAV3oRFDNgzGiV7HdlkocRw6uJCs0/w"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDA07n+GRqAPcZa8EGh4LvF57RjUOHXdp+942VJrjWqk"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTMwKGTiKKaOXosdBnAlCl7MC6CT8JAI1nZsB/1VLKV"
    ];
  };

  environment.systemPackages = with pkgs; [ neovim curl git ];

  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "24.05";
}
