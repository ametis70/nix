{ inputs, ... }:

let
  template = import ./templates/linux.nix;
  settings = {
    name = "nixos-server-2";
    uuid = "e771de7f-9c09-46ee-9dec-75909c363b3f";
    video = true;
    ram = 16;
    cpu = 4;
    disks = [
      "/media/ssd2/server-2.qcow2"
    ];
    mac = "62:d9:31:bd:67:6f";
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
