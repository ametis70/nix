{ config, lib, pkgs, ... }:

let
  cfg = config.custom.hardware.intel.graphics;
in
{
  options.custom.hardware.intel.graphics.enable = lib.mkEnableOption "Intel graphics acceleration";

  config = lib.mkIf cfg.enable {
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        intel-compute-runtime
        vpl-gpu-rt
      ];
    };
  };
}
