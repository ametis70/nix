{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot = {
      initrd = {
        availableKernelModules = [
          "ahci"
          "xhci_pci"
          "virtio_pci"
          "virtio_blk"
        ];
        kernelModules = [ "amdgpu" ];
      };
      kernelModules = [ "kvm-amd" ];
      extraModulePackages = [ ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/dec507a5-e3b0-415b-8851-f422373a8529";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/49AE-0430";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
    };

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
