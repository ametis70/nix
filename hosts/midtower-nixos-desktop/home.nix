{ pkgs, ... }:

{
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
    gaming.emulation = {
      enable = true;
      pegasus.disableHidapi = true;
    };
  };

  home.file."Desktop/Return-to-Gaming-Mode.desktop".source =
    (pkgs.makeDesktopItem {
      desktopName = "Return to Gaming Mode";
      exec = "steamosctl switch-to-game-mode";
      icon = "steam";
      name = "Return-to-Gaming-Mode";
      startupNotify = false;
      terminal = false;
      type = "Application";
    })
    + "/share/applications/Return-to-Gaming-Mode.desktop";

  custom.emulation = {
    enable = true;
    pegasus.disableHidapi = true;
  };

  home.stateVersion = "25.11";
}
