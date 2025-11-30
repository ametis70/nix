{ pkgs, ... }:

let
  edid = "fantasmagoria.bin";
in
{
  hardware.display = {
    outputs."HDMI-A-1" = {
      edid = "${edid}";
      mode = "e";
    };

    edid = {
      packages = [
        (pkgs.runCommand "edid-custom" { } ''
          mkdir -p "$out/lib/firmware/edid"
          # base64 fantasmagoria.bin
          base64 -d > "$out/lib/firmware/edid/${edid}" <<'EOF'
          AP///////wAo7ARuAQAAAAEhAQOAAAB4D3IYp1RLnyUNSGW974CBwIEAqUDRwNEAgTyB/NH8COgA
          MPJwWoCwWIoAAAAAAAAeCOiAGHE4LUBYLEUAAAAAAAAeAAAA/QAX8A+HPAAKICAgICAgAAAA/ABG
          YW50YXNtYWdvcmlhAVkCA0lwUWFgX15dEB8gISIEExECPwMSNQ9/Bz0ewBUHUF9+A1cGA2d+A19+
          AYNfAABtAwwAEAA4RC+AYAECA2fYXcQBeIAD4gD/Vl4AoKCgKVAwIDUAUB10AAAab8IAoKCgVVAw
          IDUAUB10AAAeAAAAAAAAAAAAAAAAAAAAAAAArA==
          EOF
        '')
      ];
    };
  };
}
