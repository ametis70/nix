{ pkgs, lib, ... }:

{
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [
      utsushi
      utsushi-networkscan
      sane-airscan
    ];
  };

  users.users.ametis70.extraGroups = [
    "scanner"
    "lp"
  ];

  services.udev.packages = with pkgs; [
    utsushi
    utsushi-networkscan
    sane-airscan
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.ipp-usb.enable = true;

  environment.etc."utsushi/utsushi.conf".text = ''
    [devices]
    dev1.udi     = esci:networkscan://192.168.10.6:1865
    dev1.name    = Epson DS-40 (WiFi)
    dev1.vendor  = EPSON
    dev1.model   = DS-40

    dev2.udi     = esci:usb:04b8:0152
    dev2.name    = Epson DS-40 (USB)
    dev2.vendor  = EPSON
    dev2.model   = DS-40
  '';
}
