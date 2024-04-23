{
  description = "ametis70's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      packages = {
        "x86_64-linux" = nixpkgs.legacyPackages."x86_64-linux";
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
