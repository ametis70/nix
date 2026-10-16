{ config, lib, ... }:

let
  cfg = config.custom.hardware.amd.gpu;
in
{
  options.custom.hardware.amd.gpu = {
    enable = lib.mkEnableOption "AMD GPU graphics support";

    rocm.enable = lib.mkEnableOption "ROCm and OpenCL support for AMD GPUs";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
      hardware.amdgpu.initrd.enable = true;
    })
    (lib.mkIf cfg.rocm.enable {
      hardware.amdgpu.opencl.enable = true;
      nixpkgs.config.rocmSupport = true;
    })
  ];
}
