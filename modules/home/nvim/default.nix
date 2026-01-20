{ pkgs-unstable, ... }:

{
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
