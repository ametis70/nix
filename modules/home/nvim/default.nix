{
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    imports = [ ./config ];
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };
  };
}
