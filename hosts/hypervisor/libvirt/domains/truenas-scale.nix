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
        }
      ];
    };
  };
}

# <domain type="kvm">
#   <name>truenas-scale</name>
#   <uuid>7cb531c2-60d7-4dfc-bb1f-b4771e5c76d6</uuid>
#   <memory unit="KiB">16777216</memory>
#   <currentMemory unit="KiB">16777216</currentMemory>
#   <vcpu placement="static">1</vcpu>
#   <os>
#     <type arch="x86_64" machine="pc-q35-9.1">hvm</type>
#     <boot dev="cdrom"/>
#     <boot dev="hd"/>
#   </os>
#   <features>
#     <acpi/>
#     <apic/>
#   </features>
#   <cpu mode="host-passthrough" check="none" migratable="on"/>
#   <clock offset="utc">
#     <timer name="rtc" tickpolicy="catchup"/>
#     <timer name="pit" tickpolicy="delay"/>
#     <timer name="hpet" present="no"/>
#   </clock>
#   <on_poweroff>destroy</on_poweroff>
#   <on_reboot>restart</on_reboot>
#   <on_crash>destroy</on_crash>
#   <devices>
#     <emulator>/nix/store/s3xdb71i57gbh74xx9y66a1hgkjn7y3d-qemu-9.1.2/bin/qemu-system-x86_64</emulator>
#     <disk type="file" device="disk">
#       <driver name="qemu" type="qcow2" cache="none" discard="unmap"/>
#       <source file="/var/lib/libvirt/images/truenas-scale.qcow2"/>
#       <target dev="vda" bus="virtio"/>
#       <address type="pci" domain="0x0000" bus="0x04" slot="0x00" function="0x0"/>
#     </disk>
#     <disk type="file" device="cdrom">
#       <driver name="qemu" type="raw"/>
#       <target dev="sdc" bus="sata"/>
#       <readonly/>
#       <address type="drive" controller="0" bus="0" target="0" unit="2"/>
#     </disk>
#     <controller type="usb" index="0" model="qemu-xhci">
#       <address type="pci" domain="0x0000" bus="0x02" slot="0x00" function="0x0"/>
#     </controller>
#     <controller type="sata" index="0">
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x1f" function="0x2"/>
#     </controller>
#     <controller type="pci" index="0" model="pcie-root"/>
#     <controller type="pci" index="1" model="pcie-root-port">
#       <model name="pcie-root-port"/>
#       <target chassis="1" port="0x10"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x0" multifunction="on"/>
#     </controller>
#     <controller type="pci" index="2" model="pcie-root-port">
#       <model name="pcie-root-port"/>
#       <target chassis="2" port="0x11"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x1"/>
#     </controller>
#     <controller type="pci" index="3" model="pcie-root-port">
#       <model name="pcie-root-port"/>
#       <target chassis="3" port="0x12"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x2"/>
#     </controller>
#     <controller type="pci" index="4" model="pcie-root-port">
#       <model name="pcie-root-port"/>
#       <target chassis="4" port="0x13"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x3"/>
#     </controller>
#     <controller type="pci" index="5" model="pcie-root-port">
#       <model name="pcie-root-port"/>
#       <target chassis="5" port="0x14"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x4"/>
#     </controller>
#     <controller type="pci" index="6" model="pcie-root-port">
#       <model name="pcie-root-port"/>
#       <target chassis="6" port="0x15"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x5"/>
#     </controller>
#     <controller type="pci" index="7" model="pcie-root-port">
#       <model name="pcie-root-port"/>
#       <target chassis="7" port="0x16"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x02" function="0x6"/>
#     </controller>
#     <controller type="virtio-serial" index="0">
#       <address type="pci" domain="0x0000" bus="0x03" slot="0x00" function="0x0"/>
#     </controller>
#     <interface type="bridge">
#       <mac address="52:54:00:7c:23:d1"/>
#       <source bridge="virbr0"/>
#       <model type="virtio"/>
#       <address type="pci" domain="0x0000" bus="0x01" slot="0x00" function="0x0"/>
#     </interface>
#     <channel type="spicevmc">
#       <target type="virtio" name="com.redhat.spice.0"/>
#       <address type="virtio-serial" controller="0" bus="0" port="1"/>
#     </channel>
#     <channel type="unix">
#       <target type="virtio" name="org.qemu.guest_agent.0"/>
#       <address type="virtio-serial" controller="0" bus="0" port="2"/>
#     </channel>
#     <input type="tablet" bus="usb">
#       <address type="usb" bus="0" port="2"/>
#     </input>
#     <input type="mouse" bus="ps2"/>
#     <input type="keyboard" bus="ps2"/>
#     <graphics type="spice">
#       <listen type="none"/>
#       <image compression="off"/>
#       <gl enable="no"/>
#     </graphics>
#     <sound model="ich9">
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x1b" function="0x0"/>
#     </sound>
#     <audio id="1" type="spice"/>
#     <video>
#       <model type="qxl" ram="65536" vram="65536" vgamem="16384" heads="1" primary="yes"/>
#       <address type="pci" domain="0x0000" bus="0x00" slot="0x01" function="0x0"/>
#     </video>
#     <redirdev bus="usb" type="spicevmc">
#       <address type="usb" bus="0" port="3"/>
#     </redirdev>
#     <redirdev bus="usb" type="spicevmc">
#       <address type="usb" bus="0" port="4"/>
#     </redirdev>
#     <redirdev bus="usb" type="spicevmc">
#       <address type="usb" bus="0" port="1.1"/>
#     </redirdev>
#     <redirdev bus="usb" type="spicevmc">
#       <address type="usb" bus="0" port="1.2"/>
#     </redirdev>
#     <hub type="usb">
#       <address type="usb" bus="0" port="1"/>
#     </hub>
#     <watchdog model="itco" action="reset"/>
#     <memballoon model="virtio">
#       <address type="pci" domain="0x0000" bus="0x05" slot="0x00" function="0x0"/>
#     </memballoon>
#     <rng model="virtio">
#       <backend model="random">/dev/urandom</backend>
#       <address type="pci" domain="0x0000" bus="0x06" slot="0x00" function="0x0"/>
#     </rng>
#   </devices>
# </domain>
