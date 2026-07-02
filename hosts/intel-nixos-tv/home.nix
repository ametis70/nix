{ pkgs, inputs, ... }:

let
  res4k = {
    width = 3840;
    height = 2160;
    refresh = 60;
  };
  res2k = {
    width = 2560;
    height = 1440;
    refresh = 120;
  };
  res1080 = {
    width = 1920;
    height = 1080;
    refresh = 120;
  };
in
{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/fonts/fonts.nix
    ../../modules/home/kitty/kitty.nix

    ../../modules/home/emulation

    inputs.launchscope.homeManagerModules.default
  ];

  custom.emulation = {
    enable = true;
    pegasus.disableHidapi = true;
  };

  programs.launchscope = {
    enable = true;
    settings = {
      cec = {
        enabled = true;
      };
      ui = {
        font = "departure-mono";
        scale = 1.0;
        icons = "pixel";
        display = {
          fullscreen = true;
          output = res2k;
        };
        idle = {
          dim_timeout = 60 * 3;
          blank_timeout = 60 * 6;
          blank_mode = "cec";
          cec_activate_on_start = true;
        };
        background = {
          type = "shader";
          animate = true;
        };
      };
      apps = [
        {
          id = "kodi";
          name = "Kodi";
          exec = "${pkgs.kodi-gbm}/bin/kodi-standalone";
          gamescope = {
            enabled = false;
          };
        }
        {
          id = "moonlight";
          name = "Moonlight";
          exec = "${pkgs.moonlight-qt}/bin/moonlight";
          gamescope = {
            enabled = true;
            fullscreen = true;
            output = res2k;
          };
        }
        {
          id = "pegasus";
          name = "Pegasus";
          exec = "pegasus-fe";
          gamescope = {
            enabled = true;
            fullscreen = true;
            output = res1080;
          };
        }
        {
          id = "desktop";
          name = "Desktop";
          exec = "env -u WAYLAND_DISPLAY -u DISPLAY startplasma-wayland";
          gamescope = {
            enabled = false;
          };
        }
        {
          id = "kitty";
          name = "Terminal";
          exec = "${pkgs.kitty}/bin/kitty";
          gamescope = {
            enabled = true;
            fullscreen = true;
            output = res2k;
          };
        }
        {
          id = "steam";
          name = "Steam";
          exec = "start-gamescope-session";
          gamescope = {
            enabled = false; # Jovian's start-gamescope-session manages gamescope itself
          };
        }
        {
          id = "youtube";
          name = "YouTube";
          exec = "${pkgs.vacuum-tube}/bin/VacuumTube";
          gamescope = {
            enabled = true;
            fullscreen = true;
            output = res4k;
          };
        }
      ];
    };
  };

  home.packages = with pkgs; [
    jellyfin-media-player
    pavucontrol
    ungoogled-chromium
    xdg-utils
  ];

  home.stateVersion = "25.05";
}
