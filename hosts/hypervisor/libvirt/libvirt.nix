{ config, lib, pkgs, ... }:

{
  boot.kernelParams = lib.mkDefault [
    "amd_iommu=on"
    "iommu=pt"
    "kvm.ignore_msrs=1"
    "kvm_amd.nested=1"
    "vfio-pci.ids=10de:2208,10de:1aef"
    "vfio-pci.disable-vga=1"
    "video=efifb:off"
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
        {
          definition = ./domains/archlinux-gpu.xml;
          active = false;
        }
        {
          definition = ./domains/archlinux.xml;
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
      source = config.virtualisation.libvirtd.qemu.package
        + "/share/qemu/edk2-x86_64-secure-code.fd";
    };

    "ovmf/edk2-i386-vars.fd" = {
      source = config.virtualisation.libvirtd.qemu.package
        + "/share/qemu/edk2-i386-vars.fd";
    };
  };
}
