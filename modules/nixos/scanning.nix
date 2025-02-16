{ pkgs, ... }:

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
}
