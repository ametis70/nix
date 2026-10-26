{
  lib,
  rustPlatform,
  pkg-config,
  autoPatchelfHook,
  makeWrapper,
  libusb1,
  systemd,
  alsa-lib,
  libxkbcommon,
  wayland,
  libxcb,
  libGL,
  libx11,
  libxrandr,
  libxinerama,
  libxi,
  libxxf86vm,
  darwin,
  stdenv,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "m-flasher";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "jvitkauskas";
    repo = "m-flasher";
    rev = "v${version}";
    hash = "sha256-XWUANxthaBZbrFVAcSeS/Rk8d3uh71cvh3a3XyYtOhk=";
  };

  cargoHash = "sha256-FvGIUcYb3Cu+xjXOSHkQlc4Y3R+L42gK5BWDAR/juYc=";

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
    makeWrapper
  ];

  autoPatchelfIgnoreMissingDeps = [ "libgcc_s.so.1" ];

  buildInputs =
    lib.optionals stdenv.isLinux [
      libusb1
      systemd
      alsa-lib
      libxkbcommon
      wayland
      libxcb
      libGL
      libx11
      libxrandr
      libxinerama
      libxi
      libxxf86vm
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.IOKit
    ];

  buildFeatures = lib.optional stdenv.isLinux "usb";

  postFixup = lib.optionalString stdenv.isLinux ''
    wrapProgram $out/bin/m-flasher \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libusb1
          systemd
          alsa-lib
          libxkbcommon
          wayland
          libxcb
          libGL
          libx11
          libxrandr
          libxinerama
          libxi
          libxxf86vm
        ]
      }
  '';

  meta = with lib; {
    description = "Back up, restore and install firmware of M-VAVE FM-1 and SMK-37 over USB";
    homepage = "https://github.com/jvitkauskas/m-flasher";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.unix;
  };
}
