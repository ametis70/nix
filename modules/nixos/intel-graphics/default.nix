{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.custom.intelGraphics;
in
{
  options.custom.intelGraphics.enable = lib.mkEnableOption "Intel VAAPI graphics (media-driver, compute runtime, hybrid codec)";

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
