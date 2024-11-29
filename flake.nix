{
  description = "ametis70's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable.url = "github:nix-community/home-manager";
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
      home-manager-unstable,
      nixgl,
      NixVirt,
      ...
    }@inputs:
    let
      packages = {
        "x86_64-linux" = {
          stable = (nixpkgs.legacyPackages."x86_64-linux".extend nixgl.overlay);
          unstable = (nixpkgs-unstable.legacyPackages."x86_64-linux".extend nixgl.overlay);
        };
        "aarch64-darwin" = {
          stable = nixpkgs.legacyPackages."aarch64-darwin";
          unstable = nixpkgs-unstable.legacyPackages."aarch64-darwin";
        };
      };

      nixosSystem = {
        stable = nixpkgs.lib.nixosSystem;
        unstable = nixpkgs-unstable.lib.nixosSystem;
      };

      homeManager = {
        stable = home-manager;
        unstable = home-manager-unstable;
      };

      stateVersion = {
        stable = "24.05";
        unstable = "24.11";
      };

      getHostSpecialArgs = host: {
        inherit inputs;
        inherit host;
        pkgs-unstable = packages.${host.system}.unstable;
        version = stateVersion.${host.version};
      };

      hosts = {
        work = {
          id = "work";
          hostname = "AR0FVFGD3PFQ05N";
          username = "imancini";
          system = "aarch64-darwin";
          extraNixosModules = [ ];
          version = "stable";
          nixos = false;
        };
        deck = {
          id = "deck";
          hostname = "steamdeck";
          username = "deck";
          system = "x86_64-linux";
          extraNixosModules = [ ];
          version = "stable";
          nixos = false;
        };
        windows10 = {
          id = "windows10";
          hostname = "ametis70-vm-windows";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ ];
          version = "stable";
          nixos = false;
        };
        hypervisor = {
          id = "hypervisor";
          hostname = "ametis70-hypervisor-nixos";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ NixVirt.nixosModules.default ];
          version = "stable";
          nixos = true;
        };
        nixos-vm = {
          id = "nixos-vm";
          hostname = "ametis70-vm-nixos";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ ];
          version = "stable";
          nixos = true;
        };
      };

      getHost = host: with host; "${username}@${hostname}";

      configureHomeManager =
        host:
        homeManager.${host.version}.lib.homeManagerConfiguration {
          pkgs = packages.${host.system}.${host.version};
          modules = [ ./hosts/${host.id}/home.nix ];
          extraSpecialArgs = getHostSpecialArgs host;
        };

      configureNixOs =
        host:
        nixosSystem.${host.version} {
          system = host.system;
          modules = host.extraNixosModules ++ [
            homeManager.${host.version}.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${host.username} = import ./hosts/${host.id}/home.nix;
              home-manager.extraSpecialArgs = getHostSpecialArgs host;
            }
            ./hosts/${host.id}/configuration.nix
          ];
          specialArgs = getHostSpecialArgs host;
        };

    in
    {
      # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
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
