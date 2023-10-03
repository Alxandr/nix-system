{
  description = "NixOS configuration for my personal systems";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "alxandr" ];

    substituters = [
      "https://cache.nixos.org"
    ];

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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # Format disks with nix-config
    # https://github.com/nix-community/disko
    disko = {
      # using my own branch for swap support
      url = "github:Alxandr/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A highly configurable nix flake for neovim.
    # https://github.com/jordanisaacs/neovim-flake
    neovim-flake = {
      url = "github:jordanisaacs/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # # modern window compositor
    # hyprland.url = "github:hyprwm/Hyprland/v0.27.0";
    # # community wayland nixpkgs
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # # generate iso/qcow2/docker/... image from nixos configuration
    # nixos-generators = {
    #   url = "github:nix-community/nixos-generators";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # # secrets management, lock with git commit at 2023/7/15
    # agenix.url = "github:ryantm/agenix/0d8c5325fc81daf00532e3e26c6752f7bcde1143";

    # # BASH-based DSL helpers for humans, sysadmins, and fun.
    # # https://github.com/kigster/bashmatic
    # gum = {
    #   url = "github:charmbracelet/gum";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{ flake-parts, disko, nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;
      args = { inherit inputs; };
      loc = args.inputs.self.outPath;

      evalFlakeModule = module: flake-parts.lib.evalFlakeModule args (lib.setDefaultModuleLocation loc module);

      # Step 1. Build flakeModules and evaluate them to get nixosModules
      base = evalFlakeModule (args@{ config, flake-parts-lib, ... }:
        let
          inherit (flake-parts-lib) importApply;

          moduleImportArgs = args // { inherit (config.flake) nixosModules; };
          importModule = path: importApply path moduleImportArgs;
          flakeModules = {
            lib = importModule ./flake-modules/lib.nix;
            disko = importModule ./flake-modules/vendor/disko;
            home-manager = importModule ./flake-modules/vendor/home-manager;
            multi-arch-nixos = importModule ./flake-modules/multi-arch-nixos.nix;
            installer = importModule ./flake-modules/installer;
          };

          nixosModules = {
            flake-meta = importModule ./nixos-modules/flake-meta.nix;
            disko-keys = importModule ./nixos-modules/disko-keys.nix;
            users = importModule ./nixos-modules/users.nix;
            usage = importModule ./nixos-modules/usage.nix;
            caches = importModule ./nixos-modules/caches.nix;
            update-command = importModule ./nixos-modules/update-command;
          };

          homeModules = {
            neovim = importModule ./home-modules/neovim.nix;
          };
        in
        {
          imports = [
            flakeModules.lib
            flakeModules.disko
            flakeModules.home-manager
            flakeModules.multi-arch-nixos
            flakeModules.installer
          ];

          flake = {
            path = "github:Alxandr/nix-system/feat/flake-parts";
            inherit flakeModules nixosModules homeModules;
          };

          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        }
      );

      nixosModules = base.config.flake.nixosModules;

      # Step 2. Add nixosConfigurations (depending on nixosModules) to the flake
      configurationModule = lib.setDefaultModuleLocation loc ({ config, ... }: {
        imports = [
          ./lib
          ./disko-configurations
          ./users
        ];

        nixosConfigurationsExtraSpecialArgs = {
          inherit nixosModules;
          inherit (config) flake;
          inherit (config.flake) diskoConfigurations homeModules;
        };

        perSystem.nixosConfigurations.server = ./test.nix;
      });

      final = base.extendModules {
        modules = [ configurationModule ];
      };
    in
    final.config.flake;
}
