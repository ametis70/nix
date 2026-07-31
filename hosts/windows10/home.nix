{ pkgs, inputs, ... }:

{
  custom.dev.enable = true;
  custom.hvm.enable = true;

  programs.keychain = {
    enable = true;
    agents = [
      "ssh"
    ];
    keys = [
      "id_ed25519"
    ];
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

  home.stateVersion = "24.11";
}
