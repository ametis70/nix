{
  pkgs,
  pkgs-stable,
  config,
  lib,
  ...
}:
let
  cfg = config.custom.homelab.k3s.node;
  vip = "10.0.30.10";
  addr = "https://${vip}:6443";
  # Default interface for VMs, can be overridden per host
  dev = cfg.interface;

  kubeVip = rec {
    template = builtins.readFile ./kube-vip.yml;
    manifest = builtins.replaceStrings [ "ADDRESS" "INTERFACE" ] [ vip dev ] template;
    filename = "kube-vip.yml";
  };

  manifestsDir = pkgs.runCommand "k3s-manifests" { } ''
        mkdir -p $out
        # Write the processed kube-vip manifest directly
        cat > $out/${kubeVip.filename} <<EOF
    ${kubeVip.manifest}
    EOF
  '';

  manifestFilenames = [ kubeVip.filename ];
  manifestTargetDir =
    if cfg.dataDir != "" then
      "${cfg.dataDir}/server/manifests"
    else
      "/var/lib/rancher/k3s/server/manifests";
in
{
  options.custom.homelab.k3s.node = {
    enable = lib.mkEnableOption "Run k3s in this node";

    init = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Init cluster";
    };

    role = lib.mkOption {
      type = lib.types.enum [
        "server"
        "agent"
      ];
      default = "server";
      description = "Role for this node: server or agent";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "enp1s0";
      description = "Network interface for K3s cluster communication";
    };

    nodeIp = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "10.0.30.20";
      description = ''
        Explicit node IP for K3s.
        If null, K3s auto-detects the node IP.
      '';
    };

    nodeLabels = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "dedicated=ai" ];
      description = "Kubernetes labels to apply to this node.";
    };

    nodeTaints = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "dedicated=ai:NoSchedule" ];
      description = "Kubernetes taints to apply to this node.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Data directory for this node";
    };

    useCommonVmNodeNetworking = lib.mkEnableOption "common networkd config for VM-based K3s nodes";

    vlan20MacAddress = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "MAC address used to match the VM's VLAN 20 interface.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = lib.optionals cfg.useCommonVmNodeNetworking [
      {
        assertion = cfg.vlan20MacAddress != null;
        message = "custom.homelab.k3s.node.vlan20MacAddress must be set when useCommonVmNodeNetworking is enabled.";
      }
    ];

    systemd.network = lib.mkIf cfg.useCommonVmNodeNetworking {
      enable = true;
      networks = {
        "30-enp1s0" = {
          name = "enp1s0";
          DHCP = "yes";
          dhcpV4Config.RouteMetric = 100;
        };
        "30-vlan20" = {
          name = "vlan20";
          DHCP = "yes";
          dhcpV4Config.RouteMetric = 200;
        };
      };
      links."30-vlan20" = {
        matchConfig.MACAddress = cfg.vlan20MacAddress;
        linkConfig.Name = "vlan20";
      };
    };

    systemd.services.systemd-networkd-wait-online = lib.mkIf cfg.useCommonVmNodeNetworking {
      serviceConfig.ExecStart = [
        ""
        "${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online --interface=enp1s0 --timeout=60"
      ];
    };

    age.secrets.k3s.file = ../../../secrets/k3s.age;

    environment.systemPackages = with pkgs; [
      nfs-utils
      kubernetes-helm
    ];

    services.openiscsi = {
      enable = true;
      name = "${config.networking.hostName}-initiatorhost";
    };

    systemd.services.iscsid.serviceConfig = {
      PrivateMounts = "yes";
      BindPaths = "/run/current-system/sw/bin:/bin";
    };

    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
      "L /usr/bin/mount - - - - /run/current-system/sw/bin/mount"
    ]
    ++ (lib.optionals (cfg.role == "server") (
      map (f: "C+ ${manifestTargetDir}/${f} 0644 root root - ${manifestsDir}/${f}") manifestFilenames
    ));

    boot.kernel.sysctl = {
      "fs.inotify.max_user_instances" = 4096;
      "fs.inotify.max_user_watches" = 1048576;
      "fs.inotify.max_queued_events" = 65536;
    };

    services.k3s = {
      enable = true;
      role = cfg.role;
      tokenFile = config.age.secrets.k3s.path;
      package = pkgs-stable.k3s_1_34;

      extraFlags = toString (
        [
          "--disable servicelb"
          "--disable traefik"
          "--disable-helm-controller"
          "--flannel-iface=${dev}"
        ]
        ++ lib.optionals cfg.init [
          "--tls-san ${vip}"
        ]
        ++ lib.optionals (cfg.dataDir != "") [
          "--data-dir ${cfg.dataDir}"
        ]
        ++ lib.optionals (cfg.nodeIp != null) [
          "--node-ip ${cfg.nodeIp}"
        ]
        ++ map (label: "--node-label ${label}") cfg.nodeLabels
        ++ map (taint: "--node-taint ${taint}") cfg.nodeTaints
      );

      clusterInit = cfg.init;
      serverAddr = if cfg.init == true then "" else addr;
    };
  };
}
