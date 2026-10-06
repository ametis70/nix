{ ... }:

{
  custom = {
    desktop.wm.hyprland = {
      enable = true;
      monitor = "HDMI-A-1, 2560x1440@143.98, 0x0, 1";
    };
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

  programs.aerc.enable = true;

  home.stateVersion = "24.11";
}
