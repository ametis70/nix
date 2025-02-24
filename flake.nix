{
  description = "ametis70's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable.url = "github:nix-community/home-manager";
    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.5.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixGL";

    Jovian.url = "github:Jovian-Experiments/Jovian-NixOS";

    hyprland.url = "github:hyprwm/Hyprland?submodules=1&ref=v0.45.2";

    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.45.0";
      inputs.hyprland.follows = "hyprland";
    };

    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";

    argononed = {
      url = "github:nvmd/argononed";
      flake = false;
    };

    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin-unstable.url = "github:LnL7/nix-darwin/master";
    nix-darwin-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      home-manager-unstable,
      NixVirt,
      Jovian,
      raspberry-pi-nix,
      nix-darwin,
      nix-darwin-unstable,
      ...
    }@inputs:
    let
      packages = {
        "x86_64-linux" = {
          stable = nixpkgs.legacyPackages."x86_64-linux";
          unstable = nixpkgs-unstable.legacyPackages."x86_64-linux";
        };
        "aarch64-darwin" = {
          stable = nixpkgs.legacyPackages."aarch64-darwin";
          unstable = nixpkgs-unstable.legacyPackages."aarch64-darwin";
        };
        "aarch64-linux" = {
          stable = nixpkgs.legacyPackages."aarch64-linux";
          unstable = nixpkgs-unstable.legacyPackages."aarch64-linux";
        };
      };

      nixosSystem = {
        stable = nixpkgs.lib.nixosSystem;
        unstable = nixpkgs-unstable.lib.nixosSystem;
      };

      darwinSystem = {
        stable = nix-darwin.lib.darwinSystem;
        unstable = nix-darwin-unstable.lib.darwinSystem;
      };

      homeManager = {
        stable = home-manager;
        unstable = home-manager-unstable;
      };

      getHostSpecialArgs = host: {
        inherit inputs;
        inherit host;
        pkgs-unstable = packages.${host.system}.unstable;
      };

      hosts = {
        work = {
          id = "work";
          hostname = "AR000H4F609LXL5";
          username = "imancini";
          system = "aarch64-darwin";
          extraNixosModules = [ ];
          channel = "unstable";
          nixos = false;
        };
        deck = {
          id = "deck";
          hostname = "steamdeck";
          username = "deck";
          system = "x86_64-linux";
          extraNixosModules = [ ];
          channel = "stable";
          nixos = false;
        };
        nixos-deck = {
          id = "nixos-deck";
          hostname = "ametis70-deck-nixos";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ Jovian.nixosModules.default ];
          channel = "unstable";
          nixos = true;
        };
        windows10 = {
          id = "windows10";
          hostname = "ametis70-vm-windows";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ ];
          channel = "stable";
          nixos = false;
        };
        hypervisor = {
          id = "hypervisor";
          hostname = "ametis70-hypervisor-nixos";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ NixVirt.nixosModules.default ];
          channel = "stable";
          nixos = true;
        };
        nixos-vm = {
          id = "nixos-vm";
          hostname = "ametis70-vm-nixos";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ ];
          channel = "stable";
          nixos = true;
        };
        rpi4-juglares = {
          id = "rpi4-juglares";
          hostname = "rpi4-juglares";
          username = "ametis70";
          system = "aarch64-linux";
          extraNixosModules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
            raspberry-pi-nix.nixosModules.sd-image
          ];
          channel = "stable";
          nixos = true;
        };
      };

      getHost = host: with host; "${username}@${hostname}";

      configureHomeManager =
        host:
        homeManager.${host.channel}.lib.homeManagerConfiguration {
          pkgs = packages.${host.system}.${host.channel};
          modules = [ ./hosts/${host.id}/home.nix ];
          extraSpecialArgs = getHostSpecialArgs host;
        };

      configureNixOs =
        host:
        nixosSystem.${host.channel} {
          system = host.system;
          modules = host.extraNixosModules ++ [
            ./hosts/${host.id}/configuration.nix
            homeManager.${host.channel}.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${host.username} = import ./hosts/${host.id}/home.nix;
              home-manager.extraSpecialArgs = getHostSpecialArgs host;
            }
          ];
          specialArgs = getHostSpecialArgs host;
        };

      configureDarwin =
        host:
        darwinSystem.${host.channel} {
          system = host.system;
          modules = host.extraNixosModules ++ [
            ./hosts/${host.id}/configuration.nix
            homeManager.${host.channel}.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.${host.username} = import ./hosts/${host.id}/home.nix;
              home-manager.extraSpecialArgs = getHostSpecialArgs host;
            }
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
        "${nixos-deck.hostname}" = configureNixOs nixos-deck;
        "${rpi4-juglares.hostname}" = configureNixOs rpi4-juglares;
      };

      homeConfigurations = with hosts; {
        "${getHost deck}" = configureHomeManager deck;
        "${getHost windows10}" = configureHomeManager windows10;
      };

      darwinConfigurations = with hosts; {
        "${work.hostname}" = configureDarwin work;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}
