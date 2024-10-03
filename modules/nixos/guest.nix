{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    spice-vdagent
    spice-autorandr
  ];

  services.spice-vdagentd.enable = true;
  services.spice-autorandr.enable = true;
}
