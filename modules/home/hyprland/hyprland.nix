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

  services.pasystray.enable = true;
  services.blueman-applet.enable = true;

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
        layout = "hy3";
      };
      decoration = {
        rounding = 6;
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
      "plugin:hy3" = {
        tabs = {
          height = 32;
          padding = 10;
          render_text = true;
          text_font = "Iosevka Medium";
          text_height = 12;

          # Catppuccin Mocha colors
          # active tab bar segment colors (focused tab)
          "col.active" = "rgba(1e1e2eff)"; # base (default background)
          "col.active.border" = "rgba(89b4faff)"; # blue
          "col.active.text" = "rgba(cdd6f4ff)"; # text

          # active tab bar segment colors for bars on an unfocused monitor
          "col.active_alt_monitor" = "rgba(313244ff)"; # surface0 (lighter background)
          "col.active_alt_monitor.border" = "rgba(cba6f7ff)"; # mauve (purple)
          "col.active_alt_monitor.text" = "rgba(cdd6f4ff)"; # text

          # focused tab bar segment colors (focused node in unfocused container)
          "col.focused" = "rgba(313244ff)"; # surface0 (lighter background)
          "col.focused.border" = "rgba(cba6f7ff)"; # mauve (purple)
          "col.focused.text" = "rgba(cdd6f4ff)"; # text

          # inactive tab bar segment colors
          "col.inactive" = "rgba(313244ff)"; # surface0 (lighter background)
          "col.inactive.border" = "rgba(11111bff)"; # crust (dark outline)
          "col.inactive.text" = "rgba(bac2deff)"; # subtext1

          # urgent tab bar segment colors
          "col.urgent" = "rgba(1e1e2eff)"; # base
          "col.urgent.border" = "rgba(f38ba8ff)"; # red
          "col.urgent.text" = "rgba(cdd6f4ff)"; # text

          # locked tab bar segment colors
          "col.locked" = "rgba(1e1e2eff)"; # base
          "col.locked.border" = "rgba(fab387ff)"; # peach (orange)
          "col.locked.text" = "rgba(cdd6f4ff)"; # text

          blur = false;
          opacity = 1;
        };
        autotile = {
          enable = true;
          trigger_width = 800;
          trigger_height = 500;
        };
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
        "[workspace 4 silent] Telegram"
        "[workspace 4 silent] Discord"
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
        # "$mainMod SHIFT, Q, killactive,"
        "$mainMod SHIFT, Q, hy3:killactive,"
        # "$mainMod, M, exit,"
        "$mainMod, M, exec, ${hyprexit}/bin/hyprexit"
        "$mainMod SHIFT, space, togglefloating"
        "$mainMod, D, exec, $menu"
        "$mainMod SHIFT, E, exec, $emojiPicker"
        "$mainMod SHIFT, P, exec, $passPicker"
        "$mainMod SHIFT, c, exec, chromium-browser"

        # i3-like layout controls
        "$mainMod, w, hy3:changegroup, toggletab"
        "$mainMod, e, hy3:changegroup, opposite"
        "$mainMod, f, fullscreen"
        "$mainMod, s, hy3:makegroup, h"
        "$mainMod, v, hy3:makegroup, opposite"
        "$mainMod, o, pin"
        "$mainMod, a, hy3:changefocus, raise"
        "$mainMod SHIFT, A, hy3:changefocus, lower"
        "$mainMod, space, hy3:togglefocuslayer"

        # Change focus with h/j/k/l
        "$mainMod, h, hy3:movefocus, l"
        "$mainMod, j, hy3:movefocus, d"
        "$mainMod, k, hy3:movefocus, u"
        "$mainMod, l, hy3:movefocus, r"

        # Change focus with arrow keys
        "$mainMod, left, hy3:movefocus, l"
        "$mainMod, down, hy3:movefocus, d"
        "$mainMod, up, hy3:movefocus, u"
        "$mainMod, right, hy3:movefocus, r"

        # Move focused window with h/j/k/l
        "$mainMod SHIFT, H, hy3:movewindow, l"
        "$mainMod SHIFT, J, hy3:movewindow, d"
        "$mainMod SHIFT, K, hy3:movewindow, u"
        "$mainMod SHIFT, L, hy3:movewindow, r"

        # Move focused window with arrow keys
        "$mainMod SHIFT, left, hy3:movewindow, l"
        "$mainMod SHIFT, down, hy3:movewindow, d"
        "$mainMod SHIFT, up, hy3:movewindow, u"
        "$mainMod SHIFT, right, hy3:movewindow, r"

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
        "$mainMod SHIFT, 1, hy3:movetoworkspace, 1"
        "$mainMod SHIFT, 2, hy3:movetoworkspace, 2"
        "$mainMod SHIFT, 3, hy3:movetoworkspace, 3"
        "$mainMod SHIFT, 4, hy3:movetoworkspace, 4"
        "$mainMod SHIFT, 5, hy3:movetoworkspace, 5"
        "$mainMod SHIFT, 6, hy3:movetoworkspace, 6"
        "$mainMod SHIFT, 7, hy3:movetoworkspace, 7"
        "$mainMod SHIFT, 8, hy3:movetoworkspace, 8"
        "$mainMod SHIFT, 9, hy3:movetoworkspace, 9"
        "$mainMod SHIFT, 0, hy3:movetoworkspace, 10"

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

      windowrule = [
        "match:class .*, suppress_event maximize"
        "match:class ^pavucontrol$, float on"
        "match:class ^pavucontrol$, match:float 1, center on"
        "match:initial_class ^chromium-browser$, workspace 2"
        "match:initial_class ^org\\.telegram\\.desktop$, workspace 4"
        "match:initial_class ^discord$, workspace 4"
        "match:initial_class ^chromium-browser$, no_initial_focus on"
        "match:initial_class ^org\\.telegram\\.desktop$, no_initial_focus on"
        "match:initial_class ^discord$, no_initial_focus on"
      ];

      workspace = [
        "1, persistent:true"
        "2, persistent:true"
        "3, persistent:true"
        "4, persistent:true, layoutopt:orientation:tab"
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
