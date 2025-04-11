{ inputs, ... }:

let
  template = import ./templates/linux.nix;
  settings = {
    name = "nixos-server";
    uuid = "e9719f1f-0d42-4dee-9b12-58f3b271f7e9";
    video = true;
    ram = 32;
    cpu = 6;
    disks = [
      "server.qcow2"
      {
        name = "server-gluster.qcow2";
        target = "vdb";
      }
    ];
    mac = "98:b1:c7:e9:32:1f";
  };
in
{
  virtualisation.libvirt = {
    connections."qemu:///system" = {
      domains = [
        {
          definition = inputs.NixVirt.lib.domain.writeXML (template settings);
          active = true;
        }
      ];
    };
  };
}
