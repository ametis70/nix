{ lib, config, ... }:

let
  cfg = config.custom.services.pipewire;
in
{
  options.custom.services.pipewire = {
    enable = lib.mkEnableOption "Enable PipeWire service";
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    security.rtkit.enable = true;
  };
}
