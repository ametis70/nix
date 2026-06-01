{ pkgs, lib, ... }:

{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/discord/discord.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/design/design.nix
    ../../modules/home/zathura/zathura.nix
    ../../modules/home/hypervisor-virt-manager/hvm.nix
    ../../modules/home/gnome-keyring
    ../../modules/home/pdf/pdf.nix
    ../../modules/home/video
  ];

  home.packages = with pkgs; [
    ungoogled-chromium
    telegram-desktop
    nautilus
    file-roller
    calibre
  ];

  xdg.mimeApps = {
    enable = true;

    defaultApplications =
      let
        browser = [ "chromium-browser.desktop" ];
        telegram = [ "org.telegram.desktop.desktop" ];
        zathura = [ "org.pwmt.zathura.desktop" ];
        imv = [ "imv-dir.desktop" ];
        mpv = [ "mpv.desktop" ];
        gimp = [ "gimp.desktop" ];
        inkscape = [ "org.inkscape.Inkscape.desktop" ];
        blender = [ "blender.desktop" ];
        openscad = [ "openscad.desktop" ];
        audacity = [ "audacity.desktop" ];
        krita = [ "org.kde.krita.desktop" ];
      in

      lib.genAttrs [
        # Zathura
        "application/pdf"
        "application/epub+zip"
        "application/postscript"
        "application/x-cbr"
        "application/x-cbz"
        "application/vnd.comicbook+zip"
        "application/vnd.comicbook-rar"
        "image/vnd.djvu"
        "image/x-djvu"
      ] (_: zathura)

      // lib.genAttrs [
        # imv
        "image/jpeg"
        "image/png"
        "image/gif"
        "image/webp"
        "image/bmp"
        "image/tiff"
        "image/avif"
        "image/heif"
        "image/heic"
        "image/jxl"
        "image/x-tga"
        "image/x-icon"
        "image/x-dds"
        "image/x-exr"
        "image/x-psd"
      ] (_: imv)

      // lib.genAttrs [
        # mpv audio
        "audio/mpeg"
        "audio/mp4"
        "audio/aac"
        "audio/flac"
        "audio/ogg"
        "audio/vorbis"
        "audio/opus"
        "audio/wav"
        "audio/x-wav"
        "audio/webm"
        "audio/x-matroska"
        "audio/x-ms-wma"
        "audio/x-aiff"
        "audio/midi"
        "audio/x-midi"

        # mpv video
        "video/mp4"
        "video/x-matroska"
        "video/webm"
        "video/x-msvideo"
        "video/quicktime"
        "video/x-ms-wmv"
        "video/mpeg"
        "video/ogg"
        "video/3gpp"
        "video/3gpp2"
        "video/mp2t"
        "video/x-flv"
        "video/dv"

        # playlists
        "audio/x-mpegurl"
        "application/x-mpegurl"
        "application/vnd.apple.mpegurl"
        "audio/x-scpls"
      ] (_: mpv)

      // lib.genAttrs [
        "image/x-xcf"
      ] (_: gimp)

      // lib.genAttrs [
        "image/svg+xml"
        "application/vnd.inkscape.svg+xml"
      ] (_: inkscape)

      // lib.genAttrs [
        "application/x-blender"
        "application/x-blender-project"
      ] (_: blender)

      // lib.genAttrs [
        "application/x-openscad"
        "text/x-scad"
      ] (_: openscad)

      // lib.genAttrs [
        "application/x-audacity-project"
        "application/x-audacity-project3"
      ] (_: audacity)

      // lib.genAttrs [
        "application/x-krita"
        "application/x-krita-document"
        "image/openraster"
      ] (_: krita)

      // {
        "x-scheme-handler/tg" = telegram;
        "x-scheme-handler/tonsite" = telegram;

        "text/html" = browser;
        "application/xhtml+xml" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/unknown" = browser;
      };
  };

  programs.imv = {
    enable = true;
  };

  programs.mpv = {
    enable = true;
  };

  wayland.windowManager.hyprland.settings = {
    monitor = "HDMI-A-1, 2560x1440@143.98, 0x0, 1";
  };

  custom.k3s-client.enable = true;

  home.stateVersion = "24.11";
}
