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
    enable = lib.mkEnableOption "Enable fonts";
    ui.enable = lib.mkOption {
      description = "Enable UI fonts";
      type = lib.types.bool;
      default = true;
    };

    term.enable = lib.mkOption {
      description = "Enable terminal fonts";
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
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
