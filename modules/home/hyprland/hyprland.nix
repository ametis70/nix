{ pkgs, ... }:

{

home.packages = with pkgs; [
    dunst
    wofi
    networkmanagerapplet
    slurp
    grim
    wl-clipboard
    pasystray
    qt6ct
    pavucontrol
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgb(7aa2f7)";
        "col.inactive_border" = "rgb(292e42)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      master = {
        new_status = "master";
      };
      misc = {
        force_default_wallpaper = 1;
        disable_hyprland_logo = true;
      };
      exec-once = [
        "waybar"
        "pasystray"
        "nm-applet"
        "mkdir -p ~/Pictures/screenshots"
      ];
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];
      input = {
        kb_layout = "us";
        kb_variant = "intl";

        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
            natural_scroll = false;
        };
      };
      binds = {
          allow_workspace_cycles = true;
      };
      "$mainMod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";

      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod SHIFT, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod SHIFT, space, togglefloating,"
        "$mainMod, D, exec, $menu"
        "$mainMod, B, pseudo" # dwindle
        "$mainMod, V, togglesplit" # dwindle
        "$mainMod, f, fullscreen" # dwindle

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        # "$mainMod, S, togglespecialworkspace, magic"
        # "bind = $mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces with mainMod + scroll
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Cycle between workspaces
        "$mainMod,TAB,workspace,previous"

        # Screenshots
        ''SHIFT, Print, exec, grim -g "$(slurp -d)" - | tee "$HOME/Pictures/screenshots/$(date +%Y-%m-%d-%H-%M-%S).png" | wl-copy''
        ''$mainMod SHIFT, S, exec, grim -g "$(slurp -d)" - | tee "$HOME/Pictures/screenshots/$(date +%Y-%m-%d-%H-%M-%S).png" | wl-copy''
      ];

      bindm = [
        # Move/resize windows with mainMod + LMB/RMB and dragging
      "$mainMod, mouse:272, movewindow"
      "$mainMod, mouse:273, resizewindow"
      ];

      # Volume control
      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      windowrulev2 = [ "suppressevent maximize, class:.*" ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";

      preload = [ "~/Pictures/wallpaper.jpg" ];
      wallpaper = [ ", ~/Pictures/wallpaper.jpg" ];
    };
  };
}
