{ pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home/linux.nix
    ../../modules/home/dev.nix
    ../../modules/home/hypervisor-virt-manager/hvm.nix
  ];

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
