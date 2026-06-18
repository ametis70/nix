{ pkgs, pkgs-unstable, ... }:

{
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
        enable = true;
        package = pkgs-unstable.opencode;
      };
    };
  };
}
