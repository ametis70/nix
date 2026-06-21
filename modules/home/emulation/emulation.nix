{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.emulation;

  retroarchJoypadAutoconfigMaster = pkgs.callPackage ./retroarch-joypad-autoconfig-master.nix { };

  # melonds ships with GNU_STACK RWE (executable stack) which the kernel rejects.
  # Use scanelf from pax-utils to clear the execstack flag.
  melondsPatched = pkgs.libretro.melonds.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pax-utils ];
    postFixup = (old.postFixup or "") + ''
      scanelf -Xe $out/lib/retroarch/cores/melonds_libretro.so
    '';
  });

  # The autoconfig dir is a symlink tree pointing at the master pack's subdirs,
  # built as a store derivation so joypad_autoconfig_dir stays a nix store path.
  autoconfigDir = pkgs.runCommand "retroarch-autoconfig" { } ''
    mkdir -p $out
    for dir in ${retroarchJoypadAutoconfigMaster}/share/libretro/autoconfig/*/; do
      ln -s "$dir" "$out/$(basename "$dir")"
    done
  '';

  # A single directory with symlinks to all core .so files so RetroArch can
  # discover them when launched standalone.
  coresDir = pkgs.runCommand "retroarch-cores" { } ''
    mkdir -p $out
    ${lib.concatMapStrings (
      name:
      let
        info = coresConfig.${name};
      in
      "ln -s ${info.package}/lib/retroarch/cores/${info.coreName} $out/${info.coreName}\n"
    ) (lib.attrNames coresConfig)}
  '';

  # pcsx2 hardcodes <system_dir>/pcsx2/bios/ for BIOS lookup and also writes
  # .nvm/.mec files back to that path. We use a persistent XDG data dir for those
  # files and symlink the romm-managed BIOS files into it for each launch, cleaning
  # up the symlinks afterwards so romm remains the source of truth.
  ps2LaunchWrapper = pkgs.writeShellScript "retroarch-ps2" ''
    sysdir="''${XDG_DATA_HOME:-$HOME/.local/share}/retroarch/pcsx2-system"
    biosdir="$sysdir/pcsx2/bios"
    mkdir -p "$biosdir"
    echo "[ps2-wrapper] sysdir: $sysdir"
    echo "[ps2-wrapper] game: $1"

    # Symlink BIOS files from romm into the persistent dir, lowercasing the extension
    for f in ${cfg.libraryRoot}/ps2/bios/*; do
      name="$(basename "$f")"
      base="''${name%.*}"
      ext="''${name##*.}"
      ln -sf "$f" "$biosdir/$base.''${ext,,}"
    done
    echo "[ps2-wrapper] bios dir contents:"
    ls -la "$biosdir/"

    LIBRETRO_SYSTEM_DIRECTORY="$sysdir" ${pkgs.retroarch-bare}/bin/retroarch --verbose \
      -L ${pkgs.libretro.pcsx2}/lib/retroarch/cores/pcsx2_libretro.so \
      "$1"
    echo "[ps2-wrapper] retroarch exited with code $?"

    # Remove the BIOS symlinks, keep .nvm/.mec and any other written files
    for f in ${cfg.libraryRoot}/ps2/bios/*; do
      name="$(basename "$f")"
      base="''${name%.*}"
      ext="''${name##*.}"
      rm -f "$biosdir/$base.''${ext,,}"
    done
  '';

  # For multi-disc games romm stores discs in a subdirectory and passes the
  # directory path as {file.path}. This script resolves it to the first disc
  # file: preferring disc/disk/track 1 by regex, falling back to alphabetical order.
  resolveMultiDisc = pkgs.writeShellScript "resolve-multi-disc" ''
    path="$1"
    if [ ! -d "$path" ]; then
      echo "$path"
      exit 0
    fi

    # Try to find disc/disk/track 1
    first="$(find "$path" -maxdepth 1 -type f \
      -regextype posix-extended \
      -iregex ".*(disc|disk|track)[-_ ]*1.*" \
      | sort | head -1)"

    # Fall back to first file alphabetically
    if [ -z "$first" ]; then
      first="$(find "$path" -maxdepth 1 -type f | sort | head -1)"
    fi

    echo "$first"
  '';

  # Builds a per-system multi-disc wrapper script that resolves the path
  # (file or directory) and launches retroarch with the correct core and bios.
  makeMultiDiscWrapper = systemName: corePath: biosDir:
    pkgs.writeShellScript "retroarch-multidisc-${systemName}" ''
      game="$(${resolveMultiDisc} "$1")"
      echo "[${systemName}-wrapper] resolved: $game"
      LIBRETRO_SYSTEM_DIRECTORY="${biosDir}" \
        ${pkgs.retroarch-bare}/bin/retroarch --verbose \
        -L "${corePath}" \
        "$game"
    '';

  # Unified arcade launcher that detects whether a game is a Naomi GD-ROM
  # (zip with a CHD subdir alongside it) or a regular fbneo zip, and picks
  # the right core and bios setup accordingly.
  arcadeLaunchWrapper = pkgs.writeShellScript "retroarch-arcade" ''
    game="$1"
    gamedir="$(dirname "$game")"
    gamename="$(basename "$game")"
    gamebase="''${gamename%.*}"

    # Detect Naomi GD-ROM: a zip with a same-named CHD subdir next to it
    if [ -f "$game" ] && [ -d "$gamedir/$gamebase" ]; then
      echo "[arcade-wrapper] detected Naomi GD-ROM: $game"
      tmpdir=$(mktemp -d /tmp/arcade-XXXXXX)

      for f in ${cfg.libraryRoot}/naomi/bios/*; do
        ln -s "$f" "$tmpdir/$(basename "$f")"
      done
      ln -s "$game" "$tmpdir/$gamename"
      ln -s "$gamedir/$gamebase" "$tmpdir/$gamebase"

      echo "[arcade-wrapper] launching with flycast: $tmpdir/$gamename"
      ${pkgs.retroarch-bare}/bin/retroarch --verbose \
        -L ${pkgs.libretro.flycast}/lib/retroarch/cores/flycast_libretro.so \
        "$tmpdir/$gamename"
      echo "[arcade-wrapper] exited with code $?"
      rm -rf "$tmpdir"

    else
      echo "[arcade-wrapper] detected fbneo game: $game"
      LIBRETRO_SYSTEM_DIRECTORY="${cfg.libraryRoot}/arcade/bios" \
        ${pkgs.retroarch-bare}/bin/retroarch --verbose \
        -L ${pkgs.libretro.fbneo}/lib/retroarch/cores/fbneo_libretro.so \
        "$game"
      echo "[arcade-wrapper] exited with code $?"
    fi
  '';

  coresConfig = {
    nestopia = {
      package = pkgs.libretro.nestopia;
      coreName = "nestopia_libretro.so";
    };
    snes9x = {
      package = pkgs.libretro.snes9x;
      coreName = "snes9x_libretro.so";
    };
    mupen64plus = {
      package = pkgs.libretro.mupen64plus;
      coreName = "mupen64plus_next_libretro.so";
    };
    gambatte = {
      package = pkgs.libretro.gambatte;
      coreName = "gambatte_libretro.so";
    };
    mgba = {
      package = pkgs.libretro.mgba;
      coreName = "mgba_libretro.so";
    };
    melonds = {
      package = melondsPatched;
      coreName = "melonds_libretro.so";
    };
    citra = {
      package = pkgs.libretro.citra;
      coreName = "citra_libretro.so";
    };
    genesis-plus-gx = {
      package = pkgs.libretro.genesis-plus-gx;
      coreName = "genesis_plus_gx_libretro.so";
    };
    picodrive = {
      package = pkgs.libretro.picodrive;
      coreName = "picodrive_libretro.so";
    };
    flycast = {
      package = pkgs.libretro.flycast;
      coreName = "flycast_libretro.so";
    };
    swanstation = {
      package = pkgs.libretro.swanstation;
      coreName = "swanstation_libretro.so";
    };
    pcsx2 = {
      package = pkgs.libretro.pcsx2;
      coreName = "pcsx2_libretro.so";
    };
    ppsspp = {
      package = pkgs.libretro.ppsspp;
      coreName = "ppsspp_libretro.so";
    };
    fbneo = {
      package = pkgs.libretro.fbneo;
      coreName = "fbneo_libretro.so";
    };
    beetle-saturn = {
      package = pkgs.libretro.beetle-saturn;
      coreName = "mednafen_saturn_libretro.so";
    };
    beetle-pce-fast = {
      package = pkgs.libretro.beetle-pce-fast;
      coreName = "mednafen_pce_fast_libretro.so";
    };
  };

  # Helper function to get core library path
  getCorePath = coreName: coreInfo: "${coreInfo.package}/lib/retroarch/cores/${coreInfo.coreName}";

  # Helper function to get core package
  getCorePackage = coreName: coresConfig.${coreName}.package;

  # System configurations for Pegasus metafiles
  systemConfigs = {
    nes = {
      collection = "Nintendo Entertainment System";
      shortname = "nes";
      directories = "${cfg.libraryRoot}/nes/roms";
      extensions = "nes, unf, unif, fds";
      core = "nestopia";
      launcher = "retroarch";
    };
    snes = {
      collection = "Super Nintendo Entertainment System";
      shortname = "snes";
      directories = "${cfg.libraryRoot}/snes/roms";
      extensions = "sfc, smc, fig, bs";
      core = "snes9x";
      launcher = "retroarch";
    };
    n64 = {
      collection = "Nintendo 64";
      shortname = "n64";
      directories = "${cfg.libraryRoot}/n64/roms";
      extensions = "z64, n64, v64";
      core = "mupen64plus";
      launcher = "retroarch";
    };
    gamecube = {
      collection = "Nintendo GameCube";
      shortname = "gc";
      directories = "${cfg.libraryRoot}/gamecube/roms";
      extensions = "iso, rvz, wbfs, gcm, gcz";
      launcher = "dolphin";
    };
    wii = {
      collection = "Nintendo Wii";
      shortname = "wii";
      directories = "${cfg.libraryRoot}/wii/roms";
      extensions = "iso, rvz, wbfs, wad";
      launcher = "dolphin";
    };
    gbc = {
      collection = "Game Boy Color";
      shortname = "gbc";
      directories = "${cfg.libraryRoot}/gbc/roms";
      extensions = "gbc, gb";
      core = "gambatte";
      launcher = "retroarch";
    };
    gba = {
      collection = "Game Boy Advance";
      shortname = "gba";
      directories = "${cfg.libraryRoot}/gba/roms";
      extensions = "gba";
      core = "mgba";
      launcher = "retroarch";
    };
    nds = {
      collection = "Nintendo DS";
      shortname = "nds";
      directories = "${cfg.libraryRoot}/nds/roms";
      extensions = "nds";
      core = "melonds";
      launcher = "retroarch";
    };
    "3ds" = {
      collection = "Nintendo 3DS";
      shortname = "3ds";
      directories = "${cfg.libraryRoot}/3ds/roms";
      extensions = "3ds, cia, cxi";
      core = "citra";
      launcher = "retroarch";
    };
    sms = {
      collection = "Sega Master System";
      shortname = "mastersystem";
      directories = "${cfg.libraryRoot}/sms/roms";
      extensions = "sms";
      core = "genesis-plus-gx";
      launcher = "retroarch";
    };
    gg = {
      collection = "SEGA GameGear";
      shortname = "gamegear";
      directories = "${cfg.libraryRoot}/gg/roms";
      extensions = "gg";
      core = "genesis-plus-gx";
      launcher = "retroarch";
    };
    genesis = {
      collection = "Sega Mega Drive/Genesis";
      shortname = "genesis";
      directories = "${cfg.libraryRoot}/genesis/roms";
      extensions = "md, bin, gen, smd";
      core = "genesis-plus-gx";
      launcher = "retroarch";
    };
    segacd = {
      collection = "Sega CD";
      shortname = "segacd";
      directories = "${cfg.libraryRoot}/segacd/roms";
      extensions = "iso, bin, chd, cue";
      core = "genesis-plus-gx";
      launcher = "retroarch";
    };
    x32 = {
      collection = "SEGA 32X";
      shortname = "sega32x";
      directories = "${cfg.libraryRoot}/x32/roms";
      extensions = "32x, bin, md";
      core = "picodrive";
      launcher = "retroarch";
    };
    dc = {
      collection = "Dreamcast";
      shortname = "dreamcast";
      directories = "${cfg.libraryRoot}/dc/roms";
      extensions = "chd, cdi, iso, gdi";
      core = "flycast";
      launcher = "multidisc-retroarch";
    };
    naomi = {
      collection = "Arcade";
      shortname = "arcade";
      directories = "${cfg.libraryRoot}/naomi/roms";
      extensions = "zip";
      launcher = "arcadewrapper";
    };
    psx = {
      collection = "PlayStation";
      shortname = "psx";
      directories = "${cfg.libraryRoot}/psx/roms";
      extensions = "bin, cue, iso, chd, pbp";
      core = "swanstation";
      launcher = "multidisc-retroarch";
    };
    ps2 = {
      collection = "PlayStation 2";
      shortname = "ps2";
      directories = "${cfg.libraryRoot}/ps2/roms";
      extensions = "iso, chd";
      core = "pcsx2";
      launcher = "ps2wrapper";
    };
    psp = {
      collection = "PlayStation Portable";
      shortname = "psp";
      directories = "${cfg.libraryRoot}/psp/roms";
      extensions = "iso, cso, pbp";
      core = "ppsspp";
      launcher = "retroarch";
    };
    arcade = {
      collection = "Arcade";
      shortname = "arcade";
      directories = "${cfg.libraryRoot}/arcade/roms";
      extensions = "zip, 7z";
      launcher = "arcadewrapper";
    };
    saturn = {
      collection = "Sega Saturn";
      shortname = "saturn";
      directories = "${cfg.libraryRoot}/saturn/roms";
      extensions = "chd, cue, bin, iso";
      core = "beetle-saturn";
      launcher = "retroarch";
    };
    tg16 = {
      collection = "TurboGrafx-16/PC Engine";
      shortname = "turbografx16";
      directories = "${cfg.libraryRoot}/tg16/roms";
      extensions = "pce, cue, ccd, chd";
      core = "beetle-pce-fast";
      launcher = "retroarch";
    };
    neogeoaes = {
      collection = "Neo Geo AES";
      shortname = "neogeoaes";
      directories = "${cfg.libraryRoot}/neogeoaes/roms";
      extensions = "zip";
      core = "fbneo";
      launcher = "retroarch";
    };
    neogeomvs = {
      collection = "Neo Geo MVS";
      shortname = "neogeomvs";
      directories = "${cfg.libraryRoot}/neogeomvs/roms";
      extensions = "zip";
      core = "fbneo";
      launcher = "retroarch";
    };
  };

  # Generate a metafile for a system
  generateMetafile =
    systemName: systemConfig:
    let
      launchCmd =
        if systemConfig.launcher == "dolphin" then
          "${pkgs.dolphin-emu}/bin/dolphin-emu-nogui -e \"{file.path}\""
        else if systemConfig.launcher == "ps2wrapper" then
          "${ps2LaunchWrapper} \"{file.path}\""
        else if systemConfig.launcher == "naomiwrapper" || systemConfig.launcher == "arcadewrapper" then
          "${arcadeLaunchWrapper} \"{file.path}\""
        else
          let
            corePath = getCorePath systemConfig.core coresConfig.${systemConfig.core};
            biosDir =
              if systemConfig ? biosDir then systemConfig.biosDir else "${cfg.libraryRoot}/${systemName}/bios";
          in
          if systemConfig.launcher == "multidisc-retroarch" then
            "${makeMultiDiscWrapper systemName corePath biosDir} \"{file.path}\""
          else
            "sh -c 'LIBRETRO_SYSTEM_DIRECTORY=${biosDir} ${pkgs.retroarch-bare}/bin/retroarch --verbose -L ${corePath} \"$0\"' \"{file.path}\"";
    in
    ''
      collection: ${systemConfig.collection}
      shortname: ${systemConfig.shortname}
      launch: ${launchCmd}
    '';

in
{
  options.custom.emulation = {
    enable = lib.mkEnableOption "emulation with Pegasus Frontend and RetroArch";

    libraryRoot = lib.mkOption {
      type = lib.types.str;
      default = "/srv/nfs/roms/library";
      description = "Root directory of the ROM library. Each system's ROMs are expected in a subdirectory of this path.";
    };

    pegasus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Pegasus Frontend";
      };

      disableHidapi = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Set SDL_JOYSTICK_HIDAPI=0 as a session variable. Prevents Pegasus
          from flooding the Bluetooth channel via SDL's HIDAPI backend, which
          can cause connected Bluetooth audio devices to disconnect.
        '';
      };

      systems = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = lib.attrNames systemConfigs;
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
        default = lib.attrNames coresConfig;
        description = "List of libretro cores to install";
      };

      preferredDevices = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              player = lib.mkOption {
                type = lib.types.int;
                description = "Player slot (1-based) to reserve for this device";
              };
              vendorId = lib.mkOption {
                type = lib.types.int;
                description = "USB vendor ID in decimal";
              };
              productId = lib.mkOption {
                type = lib.types.int;
                description = "USB product ID in decimal";
              };
            };
          }
        );
        default = [ ];
        description = ''
          Devices that should be preferred on a specific player slot.
          Uses RetroArch's INPUT_DEVICE_RESERVATION_PREFERRED (type 1): if the device
          is connected it will always land on the given player slot, displacing whatever
          was there before.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = lib.mkIf (cfg.pegasus.enable && cfg.pegasus.disableHidapi) {
      SDL_JOYSTICK_HIDAPI = "0";
    };

    home.packages = lib.flatten [
      # Pegasus Frontend
      (lib.optional cfg.pegasus.enable pkgs.pegasus-frontend)

      # RetroArch and LibRetro cores
      (lib.optionals cfg.retroarch.enable (
        [ pkgs.retroarch-bare ] ++ map getCorePackage cfg.retroarch.cores
      ))

      # Dolphin (installed if any dolphin-based system is in the systems list)
      (lib.optional (
        cfg.pegasus.enable
        && lib.any (
          s: (systemConfigs.${s} or { launcher = "retroarch"; }).launcher == "dolphin"
        ) cfg.pegasus.systems
      ) pkgs.dolphin-emu)
    ];

    home.file = lib.mkMerge (
      lib.optional cfg.retroarch.enable (
        let
          toHex = n: lib.toLower (lib.toHexString n);
          preferredLines = lib.concatMapStrings (d: ''
            input_player${toString d.player}_reserved_device = "${toHex d.vendorId}:${toHex d.productId}"
            input_player${toString d.player}_device_reservation_type = "1"
          '') cfg.retroarch.preferredDevices;
        in
        {
          ".config/retroarch/retroarch.cfg".text = ''
            assets_directory = "${pkgs.retroarch-assets}/share/retroarch/assets"
            joypad_autoconfig_dir = "${autoconfigDir}"
            libretro_info_path = "${pkgs.libretro-core-info}/share/retroarch/cores"
            cores_directory = "${coresDir}"
            input_autodetect_enable = "true"
            config_save_on_exit = "false"
            ${preferredLines}
          '';

          ".config/retroarch/cores" = {
            source = coresDir;
            recursive = true;
          };
        }
      )
      ++ lib.optionals cfg.pegasus.enable (
        [
          {
            ".config/pegasus-frontend/game_dirs.txt".text = lib.concatMapStrings (
              system: "${systemConfigs.${system}.directories}\n"
            ) cfg.pegasus.systems;
          }
        ]
        ++ map (system: {
          ".config/pegasus-frontend/metafiles/${system}.pegasus.metadata.txt".text =
            generateMetafile system
              systemConfigs.${system};
        }) cfg.pegasus.systems
      )
    );

    home.activation.retroarchPs2Defaults = lib.mkIf cfg.retroarch.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                optFile="$HOME/.config/retroarch/config/LRPS2/LRPS2.opt"
                if [ ! -f "$optFile" ]; then
                  mkdir -p "$(dirname "$optFile")"
                  cat > "$optFile" <<'EOF'
        pcsx2_renderer = "Vulkan"
        EOF
                fi
      ''
    );
  };
}
