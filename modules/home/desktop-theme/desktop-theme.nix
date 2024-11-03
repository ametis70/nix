{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [ ../fonts/fonts.nix ];

  home.packages = with pkgs; [
    phinger-cursors
    gnome-themes-extra
    papirus-icon-theme
    adwaita-qt
    adwaita-qt6
  ];

  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    font = {
      name = "Noto Sans";
      size = 12;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  xdg.configFile = {
    qt5ct = {
      target = "qt5ct/qt5ct.conf";
      text = lib.generators.toINI { } {
        Appearance = {
          icon_theme = "Papirus-Dark";
          style = "Adwaita-Dark";
        };
        Fonts = {
          fixed = "Iosevka Medium,14,-1,5,57,0,0,0,0,0,Regular";
          general = "Noto Sans,12,-1,5,50,0,0,0,0,0";
        };
      };
    };

    qt6ct = {
      target = "qt6ct/qt6ct.conf";
      text = lib.generators.toINI { } {
        Appearance = {
          icon_theme = "Papirus-Dark";
          style = "Adwaita-Dark";
        };
        Fonts = {
          fixed = "Iosevka,14,-1,5,500,0,0,0,0,0,0,0,0,0,0,1,Regular";
          general = "Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular";
        };
      };
    };

    kdeglobals = {
      target = "kdeglobals";
      text = lib.generators.toINI { } {
        "Colors:View" = {
          BackgroundNormal = "#2E2E2E";
        };
      };
    };
  };

  qt = {
    enable = true;
    platformTheme = {
      name = "adwaita";
    };
    style = {
      name = "adwaita-dark";
    };
  };

  wayland.windowManager.hyprland.settings.env =
    lib.mkIf config.wayland.windowManager.hyprland.enable
      [
        "QT_QPA_PLATFORMTHEME,qt6ct"
        "GTK_THEME,Adwaita-dark"
      ];
}
