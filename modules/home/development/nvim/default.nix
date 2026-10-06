{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.development.nvim;
in
{
  options.custom.development.nvim = {
    enable = lib.mkEnableOption "Enable Neovim";
  };

  config = lib.mkIf cfg.enable {

    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      imports = [ ./config ];
      nixpkgs = {
        hostPlatform = pkgs.stdenv.hostPlatform.system;
        buildPlatform = pkgs.stdenv.buildPlatform.system;
        config = {
          allowUnfree = true;
        };
      };

      extraPackages = with pkgs; [
        prettier
      ];

      dependencies = {
        claude-code.enable = false;
        gemini.enable = false;
        opencode = {
          enable = false;
        };
      };
    };
  };
}
