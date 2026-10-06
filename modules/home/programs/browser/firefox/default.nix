{
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.browser.firefox;
in
{
  options.custom.programs.browser.firefox = {
    enable = lib.mkEnableOption "Enable Firefox browser";
  };

  config = lib.mkMerge [
    {
      custom.programs.browser.firefox.enable = lib.mkDefault config.custom.programs.browser.enable;
    }
    (lib.mkIf cfg.enable {
      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";
      };
    })
  ];
}
