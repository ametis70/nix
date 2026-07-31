{
  lib,
  pkgs,
  config,
  options,
  host,
  ...
}:

# Base home environment: the always-on package set + core programs that every
# host got via the old common.nix, plus the platform-specific bits that used to
# live in macos.nix / linux.nix / nixos.nix (home directory + pinentry/clipboard
# packages), now derived from `host`.
let
  cfg = config.custom.base;

  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  # Only enable programs.delta on channels where the option exists (it is
  # provided by an unstable-only home-manager module on some hosts).
  hmHas = path: lib.hasAttrByPath path options;
in
{
  options.custom.base.enable =
    lib.mkEnableOption "base home environment (core packages, shell tooling)"
    // {
      default = true;
    };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.username = host.username;
      home.homeDirectory = if isDarwin then "/Users/${host.username}" else "/home/${host.username}";

      home.packages =
        (with pkgs; [
          fd
          curl
          jq
          ranger
          wol
          rbw
          git
          rsync
          openssl
          pwgen
          mosh
        ])
        ++ lib.optionals isDarwin (with pkgs; [
          pinentry_mac
          pngpaste
        ])
        ++ lib.optionals (isLinux && !host.nixos) (with pkgs; [
          pinentry-curses
          xclip
          wl-clipboard
        ]);

      programs = {
        home-manager.enable = true;
        fzf = {
          enable = true;
          enableZshIntegration = true;
          defaultOptions = [
            "--highlight-line"
            "--info=inline-right"
            "--ansi"
            "--layout=reverse"
            "--border=none"
          ];
        };
        bat = {
          enable = true;
        };
        lazygit = {
          enable = true;
        };
        direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv = {
            enable = true;
          };
        };
        tmux = {
          enable = true;
          mouse = true;
          prefix = "C-a";
          keyMode = "vi";
          historyLimit = 5000;
          baseIndex = 1;
          extraConfig = ''
            set-option -g set-clipboard on
          '';
        };
      };
    }
    (lib.optionalAttrs (hmHas [
      "programs"
      "delta"
    ]) {
      programs.delta = {
        enable = true;
        enableGitIntegration = true;
      };
    })
  ]);
}
