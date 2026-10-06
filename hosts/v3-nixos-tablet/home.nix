{ pkgs, ... }:

{
  home.packages = with pkgs; [
    pinentry-qt
    pi-coding-agent
  ];

  custom = {
    development = {
      nvim.enable = true;
      opencode.enable = true;
    };
    programs = {
      browser.enable = true;
      chat.enable = true;
      media.enable = true;
      terminal.enable = true;
    };
    homelab.client.enable = true;
    hypervisor.client.enable = true;
  };

  home.stateVersion = "25.11";
}
