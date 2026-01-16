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
      {
        type = "block";
        driver = "raw";
        name = "/dev/mapper/vg_ssd1-server1_disk";
      }
    ];
    bridge = "br30";
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
