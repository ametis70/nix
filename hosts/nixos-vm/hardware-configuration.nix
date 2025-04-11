{
  lib,
  modulesPath,
  pkgs,
  ...
}:

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

  hardware.display.edid = {
    enable = true;
    packages = [
      (pkgs.runCommand "edid-custom" { } ''
        mkdir -p "$out/lib/firmware/edid"
        base64 -d > "$out/lib/firmware/edid/g27q.bin" <<'EOF'
        AP///////wAcVAknAQAAACUfAQOAPCF4Om/VrVBHqiMKUFS/74DRwNHo0fyVAJBAgYCBQIHAVl4A
        oKCgKVAwIDUAVVAhAAAaAAAA/wAyMTM3MkIwMDQ4NzMKAAAA/ABHMjdRCiAgICAgICAgAAAA/QAw
        kBjePAAKICAgICAgASsCA1vxUJAFBAMCYGEBFB8SEx4vWT81CX8HD38HFwdQPx7AX34BVwYAZ34H
        g08AAGcDDAAiADh4Z9hdxAF4gAPjBf8B4g8D5gYHAWRhHG0aAAACETCQ5gAAAAAAkOIAoKCgKVAw
        IDUAuokhAAAab8IAoKCgVVAwIDUAuokhAAAayQ==
        EOF
      '')
    ];
  };

  hardware.display.outputs.HDMI-A-1.edid = "g27q.bin";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
