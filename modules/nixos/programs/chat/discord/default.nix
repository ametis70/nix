{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.custom.programs.chat.discord;
in
{
  options.custom.programs.chat.discord = {
    enable = lib.mkEnableOption "Enable Discord";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePackages = [
      "discord"
      "discord-unwrapped"
    ];

    environment.systemPackages = with pkgs; [
      discord
    ];
  };
}
