{
  pkgs,
  host,
  hyprland,
  hy3,
  ...
}:

let
  hyprexit = pkgs.writeShellScriptBin "hyprexit" ''
    ${pkgs.hyprland}/bin/hyprctl dispatch exit
    ${pkgs.systemd}/bin/loginctl terminate-user ${host.username}
  '';

  # Script for creating initial workspaces
  hyprws = pkgs.writeShellScriptBin "hyprws" ''
    for w in $(seq 10); do
      ${pkgs.hyprland}/bin/hyprctl dispatch workspace $w;
    done;
    ${pkgs.hyprland}/bin/hyprctl dispatch workspace 1
  '';
in
{

  imports = [
    ../wofi/wofi.nix
    ../waybar/waybar.nix
    ../dunst/dunst.nix
    ../desktop-theme/desktop-theme.nix
  ];

  home.packages = with pkgs; [
    networkmanagerapplet
    slurp
    grim
    wl-clipboard
    pasystray
    pavucontrol
    hyprexit
    hyprws
    foot
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
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
      group = {
        "col.border_active" = "rgb(7aa2f7)";
        "col.border_inactive" = "rgb(292e42)";
        groupbar = {
          font_size = 12;
          height = 28;
          "col.active" = "rgb(24283B)";
          "col.inactive" = "rgb(1D202F)";
          text_color = "rgb(C0CAF5)";
        };
      };
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

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
        font_family = "Iosevka Medium";
        force_default_wallpaper = 1;
        disable_hyprland_logo = true;
        enable_anr_dialog = false;
      };
      exec-once = [
        "waybar"
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
      "$menu" = "wofi --show run";
      "$emojiPicker" = "wofi-emoji";
      "$passPicker" = "wofi-pass -s -c";

      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod SHIFT, Q, killactive,"
        # "$mainMod, M, exit,"
        "$mainMod, M, exec, ${hyprexit}/bin/hyprexit"
        "$mainMod SHIFT, space, togglefloating,"
        "$mainMod, D, exec, $menu"
        "$mainMod SHIFT, E, exec, $emojiPicker"
        "$mainMod SHIFT, P, exec, $passPicker"
        "$mainMod SHIFT, C, exec, chromium-browser"

        "$mainMod, B, pseudo" # dwindle
        "$mainMod, V, togglesplit" # dwindle
        "$mainMod, f, fullscreen" # dwindle
        "$mainMod, e, togglegroup"

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"

        "$mainMod, left, changegroupactive, b"
        "$mainMod, right, changegroupactive, f"

        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        "$mainMod, h, changegroupactive, b"
        "$mainMod, l, changegroupactive, f"

        "$mainMod, w, changegroupactive, f" # Backup cycle tabs in group

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
      bindl = [ ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "float, class:(pavucontrol)"
        "center, floating:1, class:(pavucontrol)"
        "workspace 2, class:(chromium-browser)"
        "workspace 4, class:(org.telegram.desktop)"
        "workspace 4, class:(discord)"
        "group set always,class:(org.telegram.desktop)"
        "group set always,class:(discord)"
      ];

      workspace = [
        "1, persistent:true"
        "2, persistent:true"
        "3, persistent:true"
        "4, persistent:true"
        "5, persistent:true"
        "6, persistent:true"
        "7, persistent:true"
        "8, persistent:true"
        "9, persistent:true"
        "10, persistent:true"
      ];

      plugin = [
        "${hy3.${host.channel}.packages.${pkgs.stdenv.hostPlatform.system}.hy3}/lib/libhy3.so"
      ];
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
