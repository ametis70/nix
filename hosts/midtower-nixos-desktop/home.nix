{ ... }:

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
    gaming.emulation.enable = true;
    gaming.steam.returnToGamingMode.enable = true;
  };

  home.stateVersion = "25.11";
}
