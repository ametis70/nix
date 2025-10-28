{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./domains/truenas-scale.nix
    ./domains/archlinux.nix
    ./domains/nixos-desktop.nix
    ./domains/nixos-server-1.nix
    ./domains/nixos-server-2.nix
    ./domains/nixos-server-builder.nix
  ];

  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
    "kvm.ignore_msrs=1"
    "kvm_amd.nested=1"
    "vfio-pci.ids=10de:2208,10de:1aef,1002:699f,1002:aae0"
    "vfio-pci.disable-vga=1"
    "video=efifb:off"
  ];

  environment.systemPackages = with pkgs; [
    virt-viewer
  ];

  virtualisation.libvirtd = {
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
          definition = ./domains/windows10-gpu.xml;
          active = true;
        }
        {
          definition = ./domains/windows10.xml;
          active = false;
        }
      ];
      pools = [
        {
          definition = ./pools/images.xml;
          active = true;
        }
        {
          definition = ./pools/nvram.xml;
          active = true;
        }
      ];
    };
  };

  programs.virt-manager.enable = true;

  environment.etc = {
    "ovmf/edk2-x86_64-secure-code.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package + "/share/qemu/edk2-i386-vars.fd";
    };
  };

  systemd.services.nixvirt = {
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = "20s";
    };

    unitConfig = {
      StartLimitIntervalSec = "15min";
      StartLimitBurst = 45;
    };
  };
}
