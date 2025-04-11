{ pkgs, ... }:

let
  hypervisor-virt-manager = pkgs.writeShellScriptBin "hvm" ''
    ${pkgs.virt-manager}/bin/virt-manager -c 'qemu+ssh://ametis70@hypervisor.lan/system'
  '';
in
{
  imports = [
    ../../modules/home/nixos.nix
    ../../modules/home/dev.nix
    ../../modules/home/discord/discord.nix
    ../../modules/home/kitty/kitty.nix
    ../../modules/home/hyprland/hyprland.nix
    ../../modules/home/design/design.nix
    ../../modules/home/zathura/zathura.nix
    ../../modules/home/gpg-agent/gpg-agent.nix
  ];

  home.packages = with pkgs; [
    ungoogled-chromium
    telegram-desktop
    nautilus
    file-roller

    virt-manager
    hypervisor-virt-manager

    orca-slicer
  ];

  wayland.windowManager.hyprland.settings = {
    monitor = "HDMI-A-1, 2560x1440@143.98, 0x0, 1";
  };

  home.stateVersion = "24.11";
}
