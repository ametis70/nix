{ lib, config, ... }:

let
  cfg = config.custom.pipewire;
in
{
  options.custom.pipewire.enable = lib.mkEnableOption "PipeWire audio (with PulseAudio compat)";

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
