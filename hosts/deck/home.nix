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

  home.stateVersion = "24.11";
}
