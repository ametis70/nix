{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.custom.desktop.fonts;
in
{
  options.custom.desktop.fonts = {
    ui.enable = lib.mkEnableOption "Enable UI fonts";
    term.enable = lib.mkEnableOption "Enable terminal fonts";
  };

  config = lib.mkIf (cfg.ui.enable || cfg.term.enable) {
    home.packages =
      with pkgs;
      (
        lib.optionals cfg.ui.enable [
          noto-fonts
          noto-fonts-lgc-plus
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
        ]
        ++ lib.optionals cfg.term.enable [
          iosevka
          nerd-fonts.symbols-only
          nerd-fonts.hack
        ]
      );

    fonts.fontconfig = {
      enable = true;
      defaultFonts =
        lib.optionalAttrs cfg.ui.enable {
          serif = [ "Noto Serif" ];
          emoji = [ "Noto Color Emoji" ];
          sansSerif = [ "Noto Sans" ];
        }
        // lib.optionalAttrs cfg.term.enable {
          monospace = [ "Iosevka" ];
        };
    };
  };
}
