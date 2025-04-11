{ inputs, ... }:

let
  utils = import ./templates/utils.nix;
  template = import ./templates/linux.nix;
  common = {
    ram = 24;
    cpu = 12;
    disks = [ "nixos.qcow2" ];
    mac = "52:54:00:54:b6:36";
  };
  settings = {
    gpu = common // {
      name = "nixos-gpu";
      uuid = "ca5872f8-67e3-4bd4-8f07-c82354e92826";
      video = false;
      pci = with utils; [
        (pciDevice 0 42 0 1) # USB Controller function 0x1
        (pciDevice 0 42 0 3) # USB Controller function 0x3
        (pciDevice 0 35 0 0) # GPU Video
        (pciDevice 0 35 0 1) # GPU Audio
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
