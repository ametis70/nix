# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/dec507a5-e3b0-415b-8851-f422373a8529";
    fsType = "ext4";
  };

  fileSystems."/media/ssd" = {
    device = "/dev/disk/by-uuid/01e34888-efda-4c4c-91a9-ccbce5de8214";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/49AE-0430";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 12 * 1024;
    }
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
