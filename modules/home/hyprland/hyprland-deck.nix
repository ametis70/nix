{ pkgs, ... }:

let
  modes = {
    "eDP-1" = "eDP-1, 800x1280@60, auto, 1, transform, 3";
    "DP-1" = "DP-1, 1920x1080@144, auto, 1";
  };

  sleepTime = "1";

  screenSwitchScript = pkgs.writeShellScriptBin "hyprland-switch-screen" ''
    get_monitor_id() {
      hyprctl -j monitors | jq -r --arg ID "$1" '.[] | select(.name == $ID) | .id'
    }

    move_workspaces() {
      for ws in $(hyprctl -j workspaces | jq '.[] | .id'); do
      hyprctl dispatch moveworkspacetomonitor $ws $1 2>&1 > /dev/null;
      done
    }

    enable_external() {
        hyprctl -q keyword monitor ${modes."DP-1"}
        sleep ${sleepTime}
        move_workspaces get_monitor_id "DP-1"
        sleep ${sleepTime}
        hyprctl -q keyword monitor eDP-1, disable
    }

    enable_internal() {
        hyprctl -q keyword monitor ${modes."eDP-1"}
        sleep ${sleepTime}
        move_workspaces get_monitor_id "eDP-1"
        sleep ${sleepTime}
        hyprctl -q keyword monitor DP-1, disable
    }

    hyprctl monitors | grep -q eDP-1
    is_internal_enabled=$?

    hyprctl monitors all | grep -q "Monitor DP-1"
    is_external_available=$?


    if [ "$is_external_available" -eq 0 ]; then
      if [ "$is_internal_enabled" -eq 0 ]; then
        enable_external
      else
        enable_internal
      fi
    else
      enable_internal
    fi
  '';
in
{
  home.packages = [ screenSwitchScript ];

  wayland.windowManager.hyprland.settings = {
    bind = [ "$mainMod, p, exec, ${screenSwitchScript}/bin/hyprland-switch-screen" ];
    monitor = [
      "${modes."eDP-1"}"
      "${modes."DP-1"}"
      # "DP-1, disabled"
    ];
  };
}
