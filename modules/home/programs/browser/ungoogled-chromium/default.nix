{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.browser.ungoogled-chromium;
in
{
  options.custom.programs.browser.ungoogled-chromium = {
    enable = lib.mkEnableOption "Enable ungoogled-chromium browser";
  };

  config = lib.mkMerge [
    {
      custom.programs.browser.ungoogled-chromium.enable =
        lib.mkDefault config.custom.programs.browser.enable;
    }
    (lib.mkIf cfg.enable {
      programs.chromium = {
        enable = true;
        package = pkgs.ungoogled-chromium;
      };
    })
  ];
}
