{ lib, pkgs-stable, ... }:

{
  specialisation.k3s-agent.configuration = {
    system.nixos.tags = [ "k3s-agent" ];
    system.nixos.variant_id = "k3s-agent";

    custom = {
      homelab.k3s.node = {
        enable = true;
        role = "agent";
        nodeLabels = [ "dedicated=ai" ];
        nodeTaints = [ "dedicated=ai:NoSchedule" ];

        # Set this if the Midtower host has a fixed cluster address.
        # nodeIp = "10.0.30.XX";
      };

      # Disable the desktop and gaming feature modules inherited from the
      # normal Midtower configuration. mkForce also overrides mkDefault values
      # set by dependent desktop modules (for example SDDM and KWallet).
      desktop = {
        de.plasma.enable = lib.mkForce false;
        dm.greetd.enable = lib.mkForce false;
        dm.sddm.enable = lib.mkForce false;
        keyring.gnome-keyring.enable = lib.mkForce false;
        keyring.kwallet.enable = lib.mkForce false;
        wm.hyprland.enable = lib.mkForce false;
      };

      gaming = {
        emulation.enable = lib.mkForce false;
        steam = {
          enable = lib.mkForce false;
          jovian.enable = lib.mkForce false;
          jovian.autoStart = lib.mkForce false;
          jovian.sessionWrapper = lib.mkForce false;
        };
        streaming.moonlight.enable = lib.mkForce false;
      };
    };

    # Use the stable nixpkgs package for the Kubernetes 1.34 stream.
    # At the pinned nixpkgs revision this is k3s v1.34.3+k3s1.
    services.k3s.package = pkgs-stable.k3s_1_34;
  };
}
