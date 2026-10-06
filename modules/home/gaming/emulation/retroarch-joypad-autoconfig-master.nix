{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation {
  pname = "retroarch-joypad-autoconfig";
  version = "unstable-2026-06-13";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "retroarch-joypad-autoconfig";
    rev = "86207989e43a636ee3746d190e73f25c23dc7b81";
    hash = "sha256-bh56K98TDl3zYDsdHcMY/ALcgru1NSu10PI4GRW8yE4=";
  };

  makeFlags = [
    "PREFIX=$(out)"
  ];

  meta = {
    description = "Joypad autoconfig files (master branch)";
    homepage = "https://www.libretro.com/";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
