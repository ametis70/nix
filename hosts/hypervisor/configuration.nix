{ config, lib, pkgs, specialArgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.ametis70 = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAvjO5PcjSiiAnAV3oRFDNgzGiV7HdlkocRw6uJCs0/w"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDA07n+GRqAPcZa8EGh4LvF57RjUOHXdp+942VJrjWqk"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGTMwKGTiKKaOXosdBnAlCl7MC6CT8JAI1nZsB/1VLKV"
    ];
  };

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

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    lazygit
    tmux
    ungoogled-chromium
  ];

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

  services.cockpit.enable = true;

  # Virtualisation

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.enable = true;
      ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
  };

  virtualisation.libvirt = {
    enable = true;
    swtpm.enable = false;
    connections."qemu:///system" = {
      domains = [
        {
          definition = ./libvirt/domains/windows10.xml;
          active = false;
        }
        {
          definition = ./libvirt/domains/archlinux.xml;
          active = false;
        }
      ];
      pools = [
        {
          definition = ./libvirt/pools/images.xml;
          active = true;
        }
        {
          definition = ./libvirt/pools/nvram.xml;
          active = true;
        }
      ];
    };
  };

  programs.virt-manager.enable = true;

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package
        + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package
        + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  # GUI
  services.xserver.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";
  services.desktopManager.plasma6.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  system.copySystemConfiguration = false;
  system.stateVersion = "24.05";
}
