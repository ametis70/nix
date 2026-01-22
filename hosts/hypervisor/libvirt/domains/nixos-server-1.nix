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
          address = "98:b1:c7:e9:32:1f";
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
          address = "98:b1:c7:e9:32:20"; # Different MAC for second interface
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
