{
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  config = {

    boot = {
      initrd = {
        availableKernelModules = [
          "nvme"
          "xhci_pci"
          "thunderbolt"
          "usbhid"
          "usb_storage"
          "sd_mod"
          "rtsx_pci_sdmmc"
        ];
        kernelModules = [ "dm-snapshot" ];
      };
      kernelModules = [
        "kvm-amd"
      ];
      kernelPackages = pkgs.linuxPackages_latest;
    };

    hardware = {
      cpu = {
        amd.ryzen-smu.enable = true;
        amd.updateMicrocode = true;
      };

      sensor.iio.enable = true;
      firmware = with pkgs; [
        alsa-firmware
      ];
      alsa.enablePersistence = true;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
      amdgpu = {
        initrd.enable = true;
      };
    };

    swapDevices = [
      {
        device = "/swapfile";
        size = 16 * 1024;
      }
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
