{ lib, config, ... }:

let
  cfg = config.custom.sshKeychain;
in
{
  options.custom.sshKeychain = {
    enable = lib.mkEnableOption "ssh-agent via keychain";
    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "id_ed25519" ];
      description = "Key names for keychain to load.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.keychain = {
      enable = true;
      agents = [ "ssh" ];
      keys = cfg.keys;
      enableZshIntegration = true;
      extraFlags = [
        "--noask"
        "--quiet"
      ];
    };

    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
  };
}
