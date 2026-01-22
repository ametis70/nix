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
      {
        type = "block";
        driver = "raw";
        name = "/dev/mapper/vg_ssd2-server2_disk";
      }
    ];
    interfaces = [
      {
        type = "bridge";
        model = {
          type = "virtio";
        };
        source = {
          bridge = "br30";
        };
        mac = {
          address = "62:d9:31:bd:67:6f";
        };
      }
      {
        type = "bridge";
        model = {
          type = "virtio";
        };
        source = {
          bridge = "br20";
        };
        mac = {
          address = "62:d9:31:bd:67:20"; # Different MAC for second interface
        };
      }
    ];
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
