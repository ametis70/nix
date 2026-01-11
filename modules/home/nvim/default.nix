{
  programs.nixvim = {
    enable = true;
    imports = [ ./config ];
    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };
  };
}
