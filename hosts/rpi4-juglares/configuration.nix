{
  pkgs,
  inputs,
  specialArgs,
  ...
}:

let
  iscsiIqn = "iqn.2025-03.local.nas";
  iscsiPortal = "truenas.lan";
  k3sMountUnits = [ "data-k3s.mount" ];
in
{
  imports = [
    ../../modules/nixos/common.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/user.nix

    "${inputs.argononed}/OS/nixos"
  ];

  boot.loader.systemd-boot.enable = false;

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = specialArgs.host.hostname;
    useDHCP = true;
    firewall.enable = false;
  };

  users.users.root.initialPassword = "root";

  # iSCSI

  systemd.mounts = [
    {
      name = "data-k3s.mount";
      after = [ "iscsi-login.service" ];
      what = "/dev/disk/by-path/ip-192.168.88.60:3260-iscsi-${iscsiIqn}:truenas:rpi4-juglares-lun-2-part1";
      where = "/data/k3s";
      type = "ext4";
      options = "_netdev,nofail";
    }
  ];

  services.openiscsi = {
    enable = true;
    name = "${iscsiIqn}:rpi4-juglares";
    discoverPortal = iscsiPortal;
  };

  systemd.services.iscsi-login = {
    description = "Login to iSCSI target";
    after = [
      "network.target"
      "iscsid.service"
    ];
    wants = [ "iscsid.service" ];
    serviceConfig = {
      ExecStartPre = "${pkgs.openiscsi}/bin/iscsiadm -m discovery -t sendtargets -p ${iscsiPortal}";
      ExecStart = "${pkgs.openiscsi}/bin/iscsiadm -m node -T ${iscsiIqn}:truenas:rpi4-juglares -p ${iscsiPortal} --login";
      ExecStop = "${pkgs.openiscsi}/bin/iscsiadm -m node -T ${iscsiIqn}:truenas:rpi4-juglares -p ${iscsiPortal} --logout";
      Restart = "on-failure";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Argon ONE V2 case

  disabledModules = [ "services/hardware/argonone.nix" ];

  services.argonone = {
    enable = true;
    logLevel = 4;
  };

  # k3s

  systemd.services.k3s = {
    wants = k3sMountUnits;
    requires = k3sMountUnits;
  };

  custom.k3s = {
    enable = true;
    dataDir = "/data/k3s";
  };

  system.stateVersion = "24.11";
}
