{ pkgs, ... }:

let
  caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "0d95a81d35a9f2d123a5e9430d1cfc43d55f1bb0";
    sha256 = "0sjk5l6gy1rs7chjv18dzhhim6vvw6gm1p0x2akj0jgqgz3lg92n";
  };

  # The upstream agent files include a `tools: [...]` field that opencode
  # rejects. The installer strips it (issue #386); we replicate that here.
  # Also strip `model:` to use the default model instead of haiku.
  stripAgent = src: pkgs.runCommand "caveman-agent-stripped" { } ''
    grep -v '^tools:' ${src} | grep -v '^model:' > $out
  '';
in
{
  # Add caveman plugin entry to opencode settings
  programs.opencode.settings = {
    plugin = [ "./plugins/caveman/plugin.js" ];
  };

  xdg.configFile = {
    # Plugin files
    "opencode/plugins/caveman/plugin.js".source = "${caveman}/src/plugins/opencode/plugin.js";
    "opencode/plugins/caveman/package.json".source = "${caveman}/src/plugins/opencode/package.json";
    "opencode/plugins/caveman/caveman-config.cjs".source = "${caveman}/src/hooks/caveman-config.js";

    # Commands
    "opencode/commands/caveman.md".source = "${caveman}/src/plugins/opencode/commands/caveman.md";
    "opencode/commands/caveman-commit.md".source = "${caveman}/src/plugins/opencode/commands/caveman-commit.md";
    "opencode/commands/caveman-review.md".source = "${caveman}/src/plugins/opencode/commands/caveman-review.md";
    "opencode/commands/caveman-compress.md".source = "${caveman}/src/plugins/opencode/commands/caveman-compress.md";
    "opencode/commands/caveman-stats.md".source = "${caveman}/src/plugins/opencode/commands/caveman-stats.md";
    "opencode/commands/caveman-help.md".source = "${caveman}/src/plugins/opencode/commands/caveman-help.md";

    # Skills
    "opencode/skills/caveman/SKILL.md".source = "${caveman}/skills/caveman/SKILL.md";
    "opencode/skills/caveman-commit/SKILL.md".source = "${caveman}/skills/caveman-commit/SKILL.md";
    "opencode/skills/caveman-review/SKILL.md".source = "${caveman}/skills/caveman-review/SKILL.md";
    "opencode/skills/caveman-help/SKILL.md".source = "${caveman}/skills/caveman-help/SKILL.md";
    "opencode/skills/caveman-stats/SKILL.md".source = "${caveman}/skills/caveman-stats/SKILL.md";
    "opencode/skills/cavecrew/SKILL.md".source = "${caveman}/skills/cavecrew/SKILL.md";
    "opencode/skills/caveman-compress/SKILL.md".source = "${caveman}/skills/caveman-compress/SKILL.md";
    "opencode/skills/caveman-compress/scripts/__init__.py".source = "${caveman}/skills/caveman-compress/scripts/__init__.py";
    "opencode/skills/caveman-compress/scripts/__main__.py".source = "${caveman}/skills/caveman-compress/scripts/__main__.py";
    "opencode/skills/caveman-compress/scripts/cli.py".source = "${caveman}/skills/caveman-compress/scripts/cli.py";
    "opencode/skills/caveman-compress/scripts/compress.py".source = "${caveman}/skills/caveman-compress/scripts/compress.py";
    "opencode/skills/caveman-compress/scripts/detect.py".source = "${caveman}/skills/caveman-compress/scripts/detect.py";
    "opencode/skills/caveman-compress/scripts/validate.py".source = "${caveman}/skills/caveman-compress/scripts/validate.py";

    # Agents — upstream files have an unsupported `tools` field; strip it on copy
    "opencode/agents/cavecrew-investigator.md".source = stripAgent "${caveman}/agents/cavecrew-investigator.md";
    "opencode/agents/cavecrew-builder.md".source      = stripAgent "${caveman}/agents/cavecrew-builder.md";
    "opencode/agents/cavecrew-reviewer.md".source     = stripAgent "${caveman}/agents/cavecrew-reviewer.md";

    # AGENTS.md ruleset (always-on caveman base)
    "opencode/AGENTS.md".source = "${caveman}/AGENTS.md";
  };
}
