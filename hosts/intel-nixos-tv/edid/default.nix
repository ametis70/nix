{ pkgs, ... }:

let
  edid = "benq-x300g.bin";
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
          # base64 benq-x300g.bin
          base64 -d > "$out/lib/firmware/edid/${edid}" <<'EOF'
          AP///////wAJ0QRuAQAAAAEhAQOAAAB4D3IYp1RLnyUNSGW974CBwIEAqUDRwNEAgTyB/NH8COgA
          MPJwWoCwWIoAAAAAAAAeCOiAGHE4LUBYLEUAAAAAAAAeAAAA/QAX8A+HPAAKICAgICAgAAAA/ABC
          ZW5RIFBKCiAgICAgAQYCA0lwVWFgX15dEB8gISIEEwUGFREUAj8DEiMJBweDAQAAbQMMABAAOEQv
          gGABAgNn2F3EAXiAA+MF4ADiAP/mBgcBi2AS4g8DVl4AoKCgKVAwIDUAUB10AAAab8IAoKCgVVAw
          IDUAUB10AAAeAAAAAAAAAAAAAAAAAAAAAAAAQg==
          EOF
        '')
      ];
    };
  };
}
