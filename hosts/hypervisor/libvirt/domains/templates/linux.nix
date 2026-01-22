{
  name,
  uuid,
  ram ? 2,
  cpu ? 2,
  disks ? [ ],
  mac ? null, # Make mac optional
  bridge ? "br0",
  interfaces ? null, # New parameter for multiple interfaces
  video ? false,
  pci ? [ ],
}:

let
  utils = import ./utils.nix;
in
{
  type = "kvm";
  name = name;
  uuid = uuid;
  memory = {
    count = ram;
    unit = "GiB";
  };
  vcpu = {
    placement = "static";
    count = cpu;
  };
  features = {
    acpi = { };
    apic = { };
  };
  cpu = {
    mode = "host-passthrough";
    feature = [
      {
        policy = "require";
        name = "topoext";
      }
    ];
  };
  os = {
    type = "hvm";
    arch = "x86_64";
    machine = "pc-q35-8.1";
    loader = {
      readonly = true;
      type = "pflash";
      path = "/run/libvirt/nix-ovmf/edk2-x86_64-code.fd";
    };
    nvram = {
      template = "/run/libvirt/nix-ovmf/edk2-i386-vars.fd";
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
  pm = {
    "suspend-to-mem" = {
      enabled = false;
    };
    "suspend-to-disk" = {
      enabled = false;
    };
  };
  devices = {
    emulator = "/run/libvirt/nix-emulators/qemu-system-x86_64";

    disk = utils.mkDisks disks;
    interface =
      if interfaces != null then
        # Multiple interfaces configuration
        interfaces
      else
        # Single interface configuration (legacy)
        [
          (
            {
              type = "bridge";
              model = {
                type = "virtio";
              };
              source = {
                bridge = bridge;
              };
            }
            // (
              if mac != null && builtins.isString mac then
                {
                  mac = {
                    address = mac;
                  };
                }
              else
                { }
            )
          )
        ];

    rng = {
      model = "virtio";
      backend = {
        model = "random";
        source = /dev/urandom;
      };
    };

    hostdev = utils.mkPCIHostDevs pci;

    channel = [
      {
        type = "unix";
        target = {
          type = "virtio";
          name = "org.qemu.guest_agent.0";
        };
      }
    ]
    ++ (
      if video then
        [
          {
            type = "spicevmc";
            target = {
              type = "virtio";
              name = "com.redhat.spice.0";
            };
          }
        ]
      else
        [ ]
    );

    input = [
      {
        type = "mouse";
        bus = "ps2";
      }
      {
        type = "keyboard";
        bus = "ps2";
      }
    ]
    ++ (
      if video then
        [
          {
            type = "tablet";
            bus = "usb";
          }
        ]
      else
        [ ]
    );

  }
  // (
    if video then
      {
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
      }
    else
      { }
  );
}
