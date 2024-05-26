{
  description = "NixOS configuration for my personal systems";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "alxandr" ];

    substituters = [ "https://cache.nixos.org" ];

    # nix community's cache server
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    # There are many ways to reference flake inputs. The most widely used is github:owner/name/reference,
    # which represents the GitHub repository URL + branch/commit-id/tag.

    # Pin our primary nixpkgs repository. This is the main nixpkgs repository
    # we'll use for our configurations. Be very careful changing this because
    # it'll impact your entire system.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # Format disks with nix-config
    # https://github.com/nix-community/disko
    disko = {
      # using my own branch for swap support
      url = "github:nix-community/disko/v1.6.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # # modern window compositor
    # hyprland.url = "github:hyprwm/Hyprland/v0.27.0";
    # # community wayland nixpkgs
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
  };

  outputs = inputs@{ flake-parts, disko, nixpkgs, nixpkgs-unstable, ... }:
    let
      inherit (nixpkgs) lib;
      args = { inherit inputs; };
      loc = "github:Alxandr/nix-system";

      evalFlakeModule = module:
        flake-parts.lib.evalFlakeModule args
        (lib.setDefaultModuleLocation loc module);

      # Step 1. Build flakeModules and evaluate them to get nixosModules
      base = evalFlakeModule (args@{ config, flake-parts-lib, ... }:
        let
          inherit (flake-parts-lib) importApply;

          moduleImportArgs = args // { inherit (config.flake) nixosModules; };
          importFlakeModule = path: importApply path moduleImportArgs;
          importNixosModule = path:
            lib.setDefaultModuleLocation path (importFlakeModule path);
          flakeModules = {
            flake-path = importFlakeModule ./flake-modules/flake-path.nix;
            disko = importFlakeModule ./flake-modules/vendor/disko.nix;
            home-manager =
              importFlakeModule ./flake-modules/vendor/home-manager.nix;
            multi-arch-nixos =
              importFlakeModule ./flake-modules/multi-arch-nixos.nix;
            users = importFlakeModule ./flake-modules/users.nix;
            installer = importFlakeModule ./flake-modules/installer;
          };

          nixosModules = {
            flake-meta = importNixosModule ./nixos-modules/flake-meta.nix;
            nixos-meta = importNixosModule ./nixos-modules/nixos-meta.nix;
            home-manager-defaults =
              importNixosModule ./nixos-modules/home-manager-defaults.nix;
            caches = importNixosModule ./nixos-modules/caches.nix;
            # update-command = importModule ./nixos-modules/update-command;
            defaults = importNixosModule ./nixos-modules/defaults.nix;
            default-gc = importNixosModule ./nixos-modules/default-gc.nix;
            plasma = importNixosModule ./nixos-modules/plasma.nix;
          };

          homeModules = {
            # neovim = importModule ./home-modules/neovim.nix;
          };
        in {
          imports = [
            flakeModules.flake-path
            flakeModules.disko
            flakeModules.home-manager
            flakeModules.multi-arch-nixos
            flakeModules.users
            flakeModules.installer

            ./users
            ./disko-configurations
          ];

          flake = {
            path = loc;
            inherit flakeModules nixosModules homeModules;
          };

          systems = [ "x86_64-linux" "aarch64-linux" ];
        });

      nixosModules = base.config.flake.nixosModules;
      users = base.config.flake.users;

      # Step 2. Add nixosConfigurations (depending on nixosModules) to the flake
      configurationModule = lib.setDefaultModuleLocation loc ({ config, ... }: {
        nixosConfigurationsExtraSpecialArgs = {
          inherit nixosModules;
          inherit (config) flake;
          inherit (config.flake) diskoConfigurations homeModules;
        };

        allNixosConfigurations = {
          imports = [
            nixosModules.caches
            nixosModules.home-manager-defaults
            nixosModules.default-gc
            nixosModules.defaults
            nixosModules.disko
            users.alxandr
          ];
        };

        perSystem.nixosConfigurations.tv = {
          unstable = true;
          config = ./systems/tv;
        };
      });

      final = base.extendModules { modules = [ configurationModule ]; };
    in final.config.flake;
}
