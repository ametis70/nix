{
  config,
  lib,
  ...
}:

let
  cfg = config.custom.programs.media;
in
{
  options = {
    custom.programs.media.viewing.documents.enable = lib.mkEnableOption "Enable documents viewing software";
  };

  config = lib.mkMerge [
    {
      custom.programs.media.viewing.documents.enable = lib.mkDefault cfg.viewing.enable;
    }
    (lib.mkIf cfg.viewing.documents.enable {
    programs.zathura = {
      enable = cfg.viewing.documents.enable;

      options = {
        adjust-open = "best-fit";
        pages-per-row = 1;
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        zoom-min = 10;
        guioptions = "s";
        font = "Iosevka Medium 14";
        recolor = true;
        recolor-keephue = false;
        render-loading = true;
        scroll-step = 50;
        selection-clipboard = "clipboard";
        sandbox = "none";
      };
    };

    xdg.mimeApps = {
      defaultApplications =
        let
          zathura = [ "org.pwmt.zathura.desktop" ];
        in
        lib.genAttrs [
          "application/pdf"
          "application/epub+zip"
          "application/postscript"
          "application/x-cbr"
          "application/x-cbz"
          "application/vnd.comicbook+zip"
          "application/vnd.comicbook-rar"
          "image/vnd.djvu"
          "image/x-djvu"
        ] (_: zathura);
    };
    })
  ];
}
