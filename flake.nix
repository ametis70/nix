{
  description = "ametis70's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixGL";
  };

  outputs = { nixpkgs, home-manager, nixgl, ... }:
    let
      packages = {
        "x86_64-linux" = (nixpkgs.legacyPackages."x86_64-linux".extend nixgl.overlay);
        "aarch64-darwin" = nixpkgs.legacyPackages."aarch64-darwin";
      };

      hosts = {
        work = {
          id = "work";
          hostname = "AR0FVFGD3PFQ05N";
          username = "imancini";
          system = "aarch64-darwin";
        };
        deck = {
          id = "deck";
          hostname = "steamdeck";
          username = "deck";
          system = "x86_64-linux";
        };
      };

      getHost = host: with host; "${username}@${hostname}";

      configureHomeManager = host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = packages.${host.system};
          modules = [ ./hosts/${host.id}/home.nix ];
          extraSpecialArgs.host = host;
        };
    in
    {
      homeConfigurations = with hosts; {
        "${getHost work}" = configureHomeManager work;
        "${getHost deck}" = configureHomeManager deck;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
