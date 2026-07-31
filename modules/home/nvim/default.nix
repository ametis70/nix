{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.nvim;
in
{
  options.custom.nvim.enable = lib.mkEnableOption "Neovim (nixvim) configuration";

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      imports = [ ./config ];
      nixpkgs = {
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
          enable = true;
          package = pkgs-unstable.opencode;
        };
      };
    };
  };
}
