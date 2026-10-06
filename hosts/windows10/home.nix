{ ... }:

{
  custom = {
    development = {
      nvim.enable = true;
      opencode.enable = true;
    };
    programs = {
      terminal.enable = true;
    };
    hypervisor.client.enable = true;
  };

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
