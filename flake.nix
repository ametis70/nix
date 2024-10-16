{
  description = "ametis70's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.5.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixGL";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nixgl,
      NixVirt,
      ...
    }@inputs:
    let
      packages = {
        "x86_64-linux" = {
          pkgs = (nixpkgs.legacyPackages."x86_64-linux".extend nixgl.overlay);
          pkgs-unstable = (nixpkgs-unstable.legacyPackages."x86_64-linux".extend nixgl.overlay);
        };
        "aarch64-darwin" = {
          pkgs = nixpkgs.legacyPackages."aarch64-darwin";
          pkgs-unstable = nixpkgs-unstable.legacyPackages."aarch64-darwin";
        };
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
        windows10 = {
          id = "windows10";
          hostname = "ametis70-vm-windows";
          username = "ametis70";
          system = "x86_64-linux";
        };
        hypervisor = {
          id = "hypervisor";
          hostname = "ametis70-hypervisor-nixos";
          username = "ametis70";
          system = "x86_64-linux";
        };
        nixos-vm = {
          id = "nixos-vm";
          hostname = "ametis70-vm-nixos";
          username = "ametis70";
          system = "x86_64-linux";
        };
      };

      getHost = host: with host; "${username}@${hostname}";

      configureHomeManager =
        host:
        home-manager.lib.homeManagerConfiguration {
          pkgs = packages.${host.system}.pkgs;
          modules = [ ./hosts/${host.id}/home.nix ];
          extraSpecialArgs = {
            host = host;
            pkgs-unstable = packages.${host.system}.pkgs-unstable;
          };
        };

      configureNixOs =
        host:
        nixpkgs.lib.nixosSystem {
          system = host.system;
          modules = [
            NixVirt.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${host.username} = import ./hosts/${host.id}/home.nix;
              home-manager.extraSpecialArgs = {
                host = host;
                pkgs-unstable = packages.${host.system}.pkgs-unstable;
              };
            }
            ./hosts/${host.id}/configuration.nix
          ];
          specialArgs = {
            host = host;
          };
        };

    in
    {
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      nixosConfigurations = with hosts; {
        "${hypervisor.hostname}" = configureNixOs hypervisor;
        "${nixos-vm.hostname}" = configureNixOs nixos-vm;
      };

      homeConfigurations = with hosts; {
        "${getHost work}" = configureHomeManager work;
        "${getHost deck}" = configureHomeManager deck;
        "${getHost windows10}" = configureHomeManager windows10;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
