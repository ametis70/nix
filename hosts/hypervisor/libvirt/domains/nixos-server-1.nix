{ inputs, ... }:

let
  template = import ./templates/linux.nix;
  settings = {
    name = "nixos-server-1";
    uuid = "e9719f1f-0d42-4dee-9b12-58f3b271f7e9";
    video = true;
    ram = 16;
    cpu = 4;
    disks = [
      "/media/ssd1/server-1.qcow2"
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
