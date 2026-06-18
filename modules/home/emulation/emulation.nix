{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.emulation;

  # LibRetro cores configuration with their paths
  coresConfig = {
    mupen64plus = {
      package = pkgs.libretro.mupen64plus;
      coreName = "mupen64plus_next_libretro.so";
    };
    snes9x = {
      package = pkgs.libretro.snes9x;
      coreName = "snes9x_libretro.so";
    };
    genesis-plus-gx = {
      package = pkgs.libretro.genesis-plus-gx;
      coreName = "genesis_plus_gx_libretro.so";
    };
  };

  # Helper function to get core library path
  getCorePath = coreName: coreInfo: "${coreInfo.package}/lib/retroarch/cores/${coreInfo.coreName}";

  # Helper function to get core package
  getCorePackage = coreName: coresConfig.${coreName}.package;

  # System configurations for Pegasus metafiles
  systemConfigs = {
    n64 = {
      collection = "Nintendo 64";
      shortname = "n64";
      directories = "/srv/nfs/roms/library/n64/roms";
      core = "mupen64plus";
    };
  };

  # Generate a metafile for a system
  generateMetafile =
    systemName: systemConfig:
    let
      corePath = getCorePath systemConfig.core coresConfig.${systemConfig.core};
    in
    ''
      collection: ${systemConfig.collection}
      shortname: ${systemConfig.shortname}
      directories: ${systemConfig.directories}
      launch: ${pkgs.retroarch}/bin/retroarch -L ${corePath} "{file.path}"
    '';

in
{
  options.custom.emulation = {
    enable = lib.mkEnableOption "emulation with Pegasus Frontend and RetroArch";

    pegasus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Pegasus Frontend";
      };

      systems = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "n64" ];
        description = "List of systems to configure metafiles for";
      };
    };

    retroarch = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable RetroArch";
      };

      cores = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "mupen64plus" ];
        description = "List of libretro cores to install";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.flatten [
      # Pegasus Frontend
      (lib.optional cfg.pegasus.enable pkgs.pegasus-frontend)

      # LibRetro cores
      (lib.optional cfg.retroarch.enable (map getCorePackage cfg.retroarch.cores))
    ];

    programs.retroarch = lib.mkIf cfg.retroarch.enable {
      enable = true;
      settings = {
        joypad_autoconfig_dir = "${pkgs.retroarch-joypad-autoconfig}/share/libretro/autoconfig";
        input_autodetect_enable = "true";
      };
    };

    # Generate Pegasus metafiles for configured systems
    home.file = lib.mkMerge (
      lib.optionals cfg.pegasus.enable (
        map (system: {
          ".config/pegasus-frontend/metafiles/${system}.pegasus.metadata.txt" = {
            text = generateMetafile system systemConfigs.${system};
          };
        }) cfg.pegasus.systems
      )
    );
  };
}
