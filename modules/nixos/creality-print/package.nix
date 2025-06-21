{ pkgs, ... }:
let
  pname = "CrealityPrint";
  semver = "6.1.2";
  extraver = "2458";
  version = "${semver}.${extraver}";

  src = pkgs.fetchurl {
    url = "https://github.com/CrealityOfficial/CrealityPrint/releases/download/v${semver}/CrealityPrint-V${version}-x86_64-Release.AppImage";
    hash = "sha256-ILwrT0LUVOyBK3d27hQ0HCw8x1JJC5+LEOgd3PTyWj4=";
  };
  appimageContents = pkgs.appimageTools.extract {
    inherit pname version src;
    postExtract = ''
      substituteInPlace $out/${pname}.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
    '';
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;
  pkgs = pkgs;
  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  extraPkgs =
    pkgs: with pkgs; [
      gst_all_1.gst-plugins-bad
      webkitgtk_4_0
    ];
}
