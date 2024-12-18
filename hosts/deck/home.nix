{ pkgs, lib, ... }:

let
  modes = {
    "eDP-1" = "eDP-1, 800x1280@60, auto, 1, transform, 3";
    "DP-1" = "DP-1, 1920x1080@144, auto, 1";
  };

  screenSwitchScript = pkgs.writeShellScriptBin "hyprland-switch-screen" ''
    hyprctl monitors | grep -q eDP-1
    is_internal_enabled=$?

    hyprctl monitors all | grep -q "Monitor DP-1"
    is_external_available=$?

    enable_external() {
        hyprctl -q keyword monitor ${modes."DP-1"}
        sleep 2
        hyprctl -q keyword monitor eDP-1, disable
    }

    enable_internal() {
        sleep 2
        hyprctl -q keyword monitor ${modes."eDP-1"}
        hyprctl -q keyword monitor DP-1, disable
    }

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
  imports = [
    ../../modules/home/linux.nix
    ../../modules/home/discord/discord.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/design/design.nix
    ../../modules/home/zathura/zathura.nix
    ../../modules/home/gpg-agent/gpg-agent.nix
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "imagescan-plugin-networkscan"
    ];

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    nixgl.nixVulkanIntel
    ungoogled-chromium
    telegram-desktop
    gnome.nautilus
    screenSwitchScript
  ];

  wayland.windowManager.hyprland.settings = {
    bind = [ "$mainMod, p, exec, ${screenSwitchScript}/bin/hyprland-switch-screen" ];
    monitor = [
      "${modes."eDP-1"}"
      # ${modes."DP-1"}"
      "DP-1, disabled"
    ];
  };
}
