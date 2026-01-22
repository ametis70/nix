{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.k3s;
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
  options.custom.k3s = {
    enable = lib.mkEnableOption "Run k3s in this node";

    init = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Init cluster";
    };

    role = lib.mkOption {
      type = lib.types.str;
      default = "server";
      description = "Role for this node";
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "enp1s0";
      description = "Network interface for K3s cluster communication";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Data directory for this node";
    };
  };

  config = lib.mkIf cfg.enable {
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
      );
      clusterInit = cfg.init;
      serverAddr = if cfg.init == true then "" else addr;
    };
  };
}
