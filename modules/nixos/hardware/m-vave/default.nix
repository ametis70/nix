{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.hardware.m-vave;
  m-flasher = pkgs.callPackage ./package.nix { };
  smk37-download-mode = pkgs.writeShellApplication {
    name = "smk37-download-mode";
    runtimeInputs = [
      pkgs.alsa-utils
      pkgs.gawk
    ];
    text = ''
      port="$(amidi -l | awk '$3 == "SMK-37" && $4 == "Pro-Private" { print $2; exit }')"
      if [[ -z "$port" ]]; then
        echo "SMK-37 Pro Private MIDI port not found; check that it is powered on and connected over USB." >&2
        exit 1
      fi

      amidi --port="$port" --send-hex='F0 22 24 35 7D F7'
      echo "Sent DOWNLOAD MODE command to the SMK-37 Pro on $port."
    '';
  };
in
{
  options.custom.hardware.m-vave = {
    enable = lib.mkEnableOption "M-Flasher and SMK-37 Pro USB MIDI support";
  };

  config = lib.mkIf cfg.enable {
    # USB MIDI in normal mode (for the DOWNLOAD MODE command) and vendor SCSI
    # commands in download mode both need their kernel drivers available.
    boot.kernelModules = [
      "snd-usb-audio"
      "sg"
    ];

    environment.systemPackages = [
      m-flasher
      smk37-download-mode
    ];

    # Udev rules for USB download mode access (4c4a:8057)
    services.udev.extraRules = ''
      # JieLi download mode (USB disk "WL82 UBOOT1.00", 4C4A:8057): let the user
      # logged in at the computer send it SCSI commands, so that M-Flasher runs
      # without root.
      SUBSYSTEM=="scsi_generic", ATTRS{idVendor}=="4c4a", ATTRS{idProduct}=="8057", TAG+="uaccess"
      # the same for the USB device itself (a build with the `usb` feature talks to
      # it through libusb, as on macOS)
      SUBSYSTEM=="usb", ATTR{idVendor}=="4c4a", ATTR{idProduct}=="8057", TAG+="uaccess"
    '';
  };
}
