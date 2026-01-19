{
  description = "ametis70's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    NixVirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/0.5.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl-unstable = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    hyprland.url = "github:hyprwm/Hyprland?submodules=1&ref=v0.52.1";

    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.52.0";
      inputs.hyprland.follows = "hyprland";
    };

    hyprland-unstable.url = "github:hyprwm/Hyprland?submodules=1&ref=v0.53.1";

    hy3-unstable = {
      url = "github:outfoxxed/hy3?ref=hl0.53.0";
      inputs.hyprland.follows = "hyprland-unstable";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin-unstable = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "";
    };

    catppuccin.url = "github:catppuccin/nix/release-25.11";
    catppuccin-unstable.url = "github:catppuccin/nix";

    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixvim-unstable.url = "github:nix-community/nixvim";
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
      nix-darwin,
      nix-darwin-unstable,
      disko,
      nixgl,
      nixgl-unstable,
      agenix,
      ...
    }@inputs:
    let
      packages = {
        "x86_64-linux" = {
          stable = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ nixgl.overlay ];
          };
          unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            overlays = [ nixgl-unstable.overlay ];
          };
        };
        "aarch64-darwin" = {
          stable = import nixpkgs {
            system = "aarch64-darwin";
          };
          unstable = import nixpkgs-unstable {
            system = "aarch64-darwin";
          };
        };
        "aarch64-linux" = {
          stable = import nixpkgs {
            system = "aarch64-linux";
          };
          unstable = import nixpkgs-unstable {
            system = "aarch64-linux";
          };
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

      hyprland = {
        stable = inputs.hyprland;
        unstable = inputs.hyprland-unstable;
      };

      hy3 = {
        stable = inputs.hy3;
        unstable = inputs.hy3-unstable;
      };

      catppuccin = {
        stable = inputs.catppuccin;
        unstable = inputs.catppuccin-unstable;
      };

      nixvim = {
        stable = inputs.nixvim;
        unstable = inputs.nixvim-unstable;
      };

      getHostSpecialArgs = host: {
        inherit inputs;
        inherit host;
        inherit hyprland;
        inherit hy3;
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
          channel = "unstable";
          nixos = false;
        };
        windows10 = {
          id = "windows10";
          hostname = "ametis70-vm-windows10";
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
        vm-nixos-desktop = {
          id = "vm-nixos-desktop";
          hostname = "ametis70-vm-nixos";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ ];
          channel = "unstable";
          nixos = true;
        };
        vm-nixos-server-builder = {
          id = "vm-nixos-server-builder";
          hostname = "vm-nixos-server-builder";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ disko.nixosModules.disko ];
          channel = "stable";
          nixos = true;
        };
        vm-nixos-server-1 = {
          id = "vm-nixos-server-1";
          hostname = "vm-nixos-server-1";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ disko.nixosModules.disko ];
          channel = "stable";
          nixos = true;
        };
        vm-nixos-server-2 = {
          id = "vm-nixos-server-2";
          hostname = "vm-nixos-server-2";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ disko.nixosModules.disko ];
          channel = "stable";
          nixos = true;
        };
        intel-nixos-server = {
          id = "intel-nixos-server";
          hostname = "intel-nixos-server";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ disko.nixosModules.disko ];
          channel = "stable";
          nixos = true;
        };
        intel-nixos-tv = {
          id = "intel-nixos-tv";
          hostname = "intel-nixos-tv";
          username = "ametis70";
          system = "x86_64-linux";
          extraNixosModules = [ disko.nixosModules.disko ];
          channel = "stable";
          nixos = true;
        };
      };

      getHost = host: with host; "${username}@${hostname}";

      configureHomeManager =
        host:
        homeManager.${host.channel}.lib.homeManagerConfiguration {
          pkgs = packages.${host.system}.${host.channel};
          modules = [
            ./hosts/${host.id}/home.nix
            nixvim.${host.channel}.homeModules.nixvim
            catppuccin.${host.channel}.homeModules.catppuccin
          ];
          extraSpecialArgs = getHostSpecialArgs host;
        };

      configureNixOs =
        host:
        nixosSystem.${host.channel} {
          inherit (host) system;
          modules = host.extraNixosModules ++ [
            ./hosts/${host.id}/configuration.nix
            catppuccin.${host.channel}.nixosModules.catppuccin
            homeManager.${host.channel}.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.${host.username}.imports = [
                  ./hosts/${host.id}/home.nix
                  nixvim.${host.channel}.homeModules.nixvim
                  catppuccin.${host.channel}.homeModules.catppuccin
                ];
                extraSpecialArgs = getHostSpecialArgs host;
              };
            }
            agenix.nixosModules.default
          ];
          specialArgs = getHostSpecialArgs host;
        };

      configureDarwin =
        host:
        darwinSystem.${host.channel} {
          inherit (host) system;
          modules = host.extraNixosModules ++ [
            ./hosts/${host.id}/configuration.nix
            homeManager.${host.channel}.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.${host.username}.imports = [
                  ./hosts/${host.id}/home.nix
                  nixvim.${host.channel}.homeModules.nixvim
                  catppuccin.${host.channel}.homeModules.catppuccin
                ];
                extraSpecialArgs = getHostSpecialArgs host;
              };
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
        "${vm-nixos-desktop.hostname}" = configureNixOs vm-nixos-desktop;
        "${vm-nixos-server-1.hostname}" = configureNixOs vm-nixos-server-1;
        "${vm-nixos-server-2.hostname}" = configureNixOs vm-nixos-server-2;
        "${vm-nixos-server-builder.hostname}" = configureNixOs vm-nixos-server-builder;
        "${intel-nixos-server.hostname}" = configureNixOs intel-nixos-server;
        "${intel-nixos-tv.hostname}" = configureNixOs intel-nixos-tv;
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
