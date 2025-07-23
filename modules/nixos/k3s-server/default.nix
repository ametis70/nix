{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.k3s;
  vip = "192.168.88.10";
  addr = "https://${vip}:6443";
  dev = "enp1s0";

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

    systemd.tmpfiles.rules =
      [
        "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
      ]
      ++ (lib.optionals (cfg.role == "server") (
        map (
          f: "C /var/lib/rancher/k3s/server/manifests/${f} 0644 root root - ${manifestsDir}/${f}"
        ) manifestFilenames
      ));

    services.k3s = {
      enable = true;
      role = cfg.role;
      tokenFile = config.age.secrets.k3s.path;
      extraFlags = toString (
        [
          "--disable servicelb"
          "--disable traefik"
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
