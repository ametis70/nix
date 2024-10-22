{ lib, pkgs, ... }:

{
  specialisation = {
    debug.configuration = {
      system.nixos.tags = [ "debug" ];
      system.nixos.variant_id = "debug";

      boot.kernelParams = lib.mkForce [
        "amd_iommu=on"
        "iommu=pt"
        "kvm.ignore_msrs=1"
        "kvm_amd.nested=1"
      ];

      systemd.services.nixvirt.wantedBy = lib.mkForce [ ];
      systemd.services.libvirtd.wantedBy = lib.mkForce [ ];
      systemd.services.libvirt-guests.wantedBy = lib.mkForce [ ];
      systemd.sockets.libvirtd.wantedBy = lib.mkForce [ ];
      systemd.sockets.libvirt-admin.wantedBy = lib.mkForce [ ];
      systemd.sockets.libvirt-ro.wantedBy = lib.mkForce [ ];

      environment.systemPackages = with pkgs; [
        wl-clipboard
        ungoogled-chromium
      ];

      services.xserver.enable = true;
      services.displayManager.sddm.wayland.enable = true;
      services.displayManager.defaultSession = "plasma";
      services.desktopManager.plasma6.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
    };
  };
}
