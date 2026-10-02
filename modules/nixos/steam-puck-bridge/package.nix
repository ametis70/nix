{ stdenv, fetchFromGitHub, gnumake }:

stdenv.mkDerivation {
  pname = "steam-puck-bridge";
  version = "unstable-2026-08-08";

  src = fetchFromGitHub {
    owner = "benashby";
    repo = "steam-puck-bridge";
    rev = "fe319f2a53496ab729d8b09aa395c921e402e416";
    hash = "sha256-aEBi6iXlhLTIm8WNXW0tbgGNFkOfi4L6nMv5eNt6SFU=";
  };

  nativeBuildInputs = [ gnumake ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 steam-puck-bridge $out/bin/steam-puck-bridge
    install -Dm644 udev/60-steam-puck-bridge.rules $out/lib/udev/rules.d/60-steam-puck-bridge.rules
    runHook postInstall
  '';

  doCheck = false;
  meta.description = "Userspace driver for the Steam Controller Puck";
}
