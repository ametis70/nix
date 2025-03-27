{ inputs, ... }:

let
  template = import ./templates/linux.nix;
  common = {
    ram = 24;
    cpu = 12;
    disk = "nixos.qcow2";
    mac = "52:54:00:54:b6:36";
  };
  settings = {
    gpu = common // {
      name = "nixos-gpu";
      uuid = "ca5872f8-67e3-4bd4-8f07-c82354e92826";
      video = false;
      pci = [
        {
          # USB Controller function 0x1
          domain = 0;
          bus = 42; # 0x2a
          slot = 0;
          function = 1;
        }
        {
          # USB Controller function 0x3
          domain = 0;
          bus = 42; # 0x2a
          slot = 0;
          function = 3;
        }
        {
          # GPU Video
          domain = 0;
          bus = 35; # 0x23
          slot = 0;
          function = 0;
        }
        {
          # GPU audio
          domain = 0;
          bus = 35; # 0x23
          slot = 0;
          function = 1;
        }
      ];
    };
    basic = common // {
      name = "nixos";
      uuid = "81c77dfc-876c-42f9-abdb-2f8b8c36d27b";
      video = true;
    };
  };
in
{
  virtualisation.libvirt = {
    connections."qemu:///system" = {
      domains = [
        {
          definition = inputs.NixVirt.lib.domain.writeXML (template settings.gpu);
          active = true;
        }
        {
          definition = inputs.NixVirt.lib.domain.writeXML (template settings.basic);
          active = false;
        }
      ];
    };
  };
}
