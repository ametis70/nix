{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home/linux.nix
    ../../modules/home/dev.nix
    ../../modules/home/gpg-agent/gpg-agent.nix
  ];

  services.gpg-agent = {
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.keychain = {
    enable = true;
    agents = [
      "ssh"
      "gpg"
    ];
    keys = [
      "id_ed25519"
      "92D7C9EB0B70F7B3"
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

  home.packages = [
    pkgs.virt-manager
    inputs.nixgl.packages.x86_64-linux.nixGLIntel
  ];

  home.stateVersion = "24.11";
}
