{ lib, ... }:

{
  specialisation.k3s-agent.configuration = {
    system.nixos.tags = [ "k3s-agent" ];
    system.nixos.variant_id = "k3s-agent";
    boot.kernelParams = [ "video=HDMI-A-1:2560x1440@60e" ];

    systemd.network = {
      enable = true;
      netdevs."30-vlan30" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan30";
          MACAddress = "02:00:00:00:30:59";
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

    # Disable the desktop, gaming, and graphical user-environment options
    # inherited by the normal Midtower Home Manager configuration.
    home-manager.users.ametis70.custom = {
      desktop = {
        keyring.gnome-keyring.enable = lib.mkForce false;
        theme.enable = lib.mkForce false;
        wm.hyprland.enable = lib.mkForce false;
      };
      gaming = {
        emulation.enable = lib.mkForce false;
        steam.returnToGamingMode.enable = lib.mkForce false;
      };
      programs = {
        browser.enable = lib.mkForce false;
        chat.enable = lib.mkForce false;
        media.enable = lib.mkForce false;
        wm.dunst.enable = lib.mkForce false;
        wm.waybar.enable = lib.mkForce false;
        wm.wofi.enable = lib.mkForce false;
      };
    };
  };
}
