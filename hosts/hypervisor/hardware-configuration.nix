{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usbhid"
        "sd_mod"
      ];
      kernelModules = [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    blacklistedKernelModules = [ "amdgpu" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/05991aa7-d632-4f35-8a77-a32309570523";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/5187-7E28";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
