{ inputs, ... }:
let
  name = "truenas-scale";
in
{
  virtualisation.libvirt = {
    connections."qemu:///system" = {
      domains = [
        {
          definition = inputs.NixVirt.lib.domain.writeXML {
            type = "kvm";
            name = name;
            uuid = "7cb531c2-60d7-4dfc-bb1f-b4771e5c76d6";
            memory = {
              count = 16;
              unit = "GiB";
            };
            vcpu = {
              placement = "static";
              count = 4;
            };
            features = {
              acpi = { };
              apic = { };
            };
            cpu = {
              mode = "host-passthrough";
            };
            os = {
              type = "hvm";
              arch = "x86_64";
              machine = "pc-q35-8.1";
              loader = {
                readonly = true;
                type = "pflash";
                path = "/run/libvirt/nix-ovmf/OVMF_CODE.fd";
              };
              nvram = {
                template = "/run/libvirt/nix-ovmf/OVMF_VARS.fd";
                path = "/var/lib/libvirt/qemu/nvram/${name}_VARS.fd";
              };
              boot = [
                { dev = "cdrom"; }
                { dev = "hd"; }
              ];
              bootmenu = {
                enable = true;
              };
            };
            clock = {
              offset = "utc";
              timer = [
                {
                  name = "rtc";
                  tickpolicy = "catchup";
                }
                {
                  name = "pit";
                  tickpolicy = "delay";
                }
                {
                  name = "hpet";
                  present = false;
                }
              ];
            };
            devices = {
              emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";

              disk = [
                {
                  type = "file";
                  device = "disk";
                  driver = {
                    name = "qemu";
                    type = "qcow2";
                    cache = "none";
                    discard = "unmap";
                  };
                  source = {
                    file = "/var/lib/libvirt/images/truenas-scale.qcow2";
                  };
                  target = {
                    dev = "vda";
                    bus = "virtio";
                  };
                }
              ];

              interface = {
                type = "bridge";
                mac = {
                  address = "52:54:00:7c:23:d1";
                };
                model = {
                  type = "virtio";
                };
                source = {
                  bridge = "br0";
                };
              };

              channel = [
                {
                  type = "spicevmc";
                  target = {
                    type = "virtio";
                    name = "com.redhat.spice.0";
                  };
                }
                {
                  type = "unix";
                  target = {
                    type = "virtio";
                    name = "org.qemu.guest_agent.0";
                  };
                }
              ];

              input = [
                {
                  type = "tablet";
                  bus = "usb";
                }
                {
                  type = "mouse";
                  bus = "ps2";
                }
                {
                  type = "keyboard";
                  bus = "ps2";
                }
              ];

              sound = {
                model = "ich9";
              };

              audio = {
                id = 1;
                type = "spice";
              };

              graphics = {
                type = "spice";
                autoport = true;
                listen = {
                  type = "address";
                };
                image = {
                  compression = false;
                };
                gl = {
                  enable = false;
                };
              };

              video = {
                type = "qxl";
                ram = 65536;
                vram = 65536;
                vgamem = 16384;
                heads = 1;
                primary = true;
              };

              rng = {
                model = "virtio";
                backend = {
                  model = "random";
                  source = /dev/urandom;
                };
              };

              hostdev = [
                {
                  mode = "subsystem";
                  type = "pci";
                  managed = true;
                  driver = {
                    name = "vfio";
                  };
                  source = {
                    address = {
                      domain = 0;
                      bus = 44; # 0x2c
                      slot = 0;
                      function = 0;
                    };
                  };
                }
              ];

              redirdev = [
                {
                  bus = "usb";
                  type = "spicevmc";
                }
                {
                  bus = "usb";
                  type = "spicevmc";
                }
                {
                  bus = "usb";
                  type = "spicevmc";
                }
                {
                  bus = "usb";
                  type = "spicevmc";
                }
              ];
            };
          };
          active = true;
        }
      ];
    };
  };
}
