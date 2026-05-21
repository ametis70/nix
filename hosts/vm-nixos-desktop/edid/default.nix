{ pkgs, ... }:

let
  edid = "g27q.bin";
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
          # base64 g27q.bin
          base64 -d > "$out/lib/firmware/edid/${edid}" <<'EOF'
          AP///////wAcVAknAQAAACUfAQOAPCF4Om/VrVBHqiMKUFS/74DRwNHo0fyVAJBAgYCBQIHAVl4A
          oKCgKVAwIDUAVVAhAAAaAAAA/wAyMTM3MkIwMDQ4NzMKAAAA/ABHMjdRCiAgICAgICAgAAAA/QAw
          kBjePAAKICAgICAgASsCA1vxUJAFBAMCYGEBFB8SEx4vWT81CX8HD38HFwdQPx7AX34BVwYAZ34H
          g08AAGcDDAAiADh4Z9hdxAF4gAPjBf8B4g8D5gYHAWRhHG0aAAACETCQ5gAAAAAAkOIAoKCgKVAw
          IDUAuokhAAAab8IAoKCgVVAwIDUAuokhAAAayQ==
          EOF
        '')
      ];
    };
  };
}
