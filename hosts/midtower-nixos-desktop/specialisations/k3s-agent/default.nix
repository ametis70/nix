{ lib, ... }:

{
  specialisation.k3s-agent.configuration = {
    system.nixos.tags = [ "k3s-agent" ];
    system.nixos.variant_id = "k3s-agent";

    systemd.network = {
      enable = true;
      netdevs."30-vlan30" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan30";
        };
        vlanConfig.Id = 30;
      };
      networks = {
        "30-enp8s0" = {
          name = "enp8s0";
          DHCP = "yes";
          dhcpV4Config.RouteMetric = 100;
          vlan = [ "vlan30" ];
        };
        "30-vlan30" = {
          name = "vlan30";
          DHCP = "yes";
          dhcpV4Config.RouteMetric = 200;
        };
      };
    };

    custom = {
      networking = {
        networkmanager.enable = lib.mkForce false;
        networkd.enable = lib.mkForce true;
      };

      homelab.k3s.node = {
        enable = true;
        role = "agent";
        interface = "vlan30";
        nodeLabels = [ "dedicated=ai" ];
        nodeTaints = [ "dedicated=ai:NoSchedule" ];
        nodeIp = "10.0.30.89";
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
  };
}
