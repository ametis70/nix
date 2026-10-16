{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.custom.development.pi;
in
{
  options.custom.development.pi = {
    enable = lib.mkEnableOption "Enable Pi Coding Agent";
  };

  config = lib.mkIf cfg.enable {
    programs.pi-coding-agent = {
      enable = true;
      package = inputs.pi.packages.${pkgs.system}.default;
      settings = {
        packages = [
          "npm:pi-web-access"
          "npm:pi-catppuccin"
        ];
        theme = "catppuccin-latte/catppuccin-mocha";
      };
    };
  };
}
