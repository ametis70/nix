{ lib, config, ... }:

let
  cfg = config.custom.texlive;
in
{
  options.custom.texlive.enable = lib.mkEnableOption "TeX Live (latexmk, biber, beamer metropolis)";

  config = lib.mkIf cfg.enable {
    programs.texlive = {
      enable = true;
      extraPackages = tpkgs: {
        inherit (tpkgs)
          latexmk
          biber
          scheme-small
          pgfopts
          beamertheme-metropolis
          ;
      };
    };
  };
}
