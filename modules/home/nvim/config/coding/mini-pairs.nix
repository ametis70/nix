{
  plugins.mini-pairs = {
    enable = true;
    settings = {
      modes = {
        insert = true;
        command = true;
        terminal = false;
      };
      skip_next = "[=[[%w%%%'%[\"%.%`%$]]=]";
      skip_ts = [ "string" ];
      skip_unbalanced = true;
      markdown = true;
    };
  };

  extraConfigLua = ''
    -- Apply the shared mini.pairs wrapper (toggle + smarter open).
    Nix.mini.pairs(require("mini.pairs").config)
  '';
}
