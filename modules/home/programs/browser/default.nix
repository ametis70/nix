{ lib, ... }:

{
  imports = [
    ./firefox
    ./ungoogled-chromium
  ];

  options.custom.programs.browser = {
    enable = lib.mkEnableOption "Enable web browsers";
  };
}
