{
  description = "NixOS configuration for my personal systems";

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
      "recursive-nix"
      "pipe-operators"
    ];
    trusted-users = [ "alxandr" ];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://hyprland.cachix.org"
      "https://install.determinate.systems"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # Secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Format disks with nix-config
    # https://github.com/nix-community/disko
    disko = {
      url = "github:nix-community/disko/v1.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix language server
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # # modern window compositor
    # hyprland.url = "github:hyprwm/Hyprland/v0.27.0";
    # # community wayland nixpkgs
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # WSL support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Dev packages
    yoloproj = {
      url = "github:YoloDev/yoloproj";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fira Code source
    fira-code = {
      url = "github:tonsky/FiraCode/master";
      flake = false;
    };

    # Determinate
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };

  outputs =
    {
      flake-parts,
      nixpkgs,
      sops-nix,
      disko,
      home-manager,
      stylix,
      fira-code,
      nil,
      nixos-hardware,
      nix-vscode-extensions,
      nixos-wsl,
      yoloproj,
      determinate,
      ...
    }:
    let
      lib = import ./lib.nix { inherit flake-parts nixpkgs; };
      base = lib.mkStage ./00-base {
        name = "base";
        inputs = { };
      };
      users = lib.mkStage ./01-users {
        name = "users";
        inputs = { inherit base home-manager; };
      };
      workloads = lib.mkStage ./02-workloads {
        name = "workloads";
        inputs = { inherit nixpkgs; };
      };
      systems = lib.mkStage ./03-systems {
        name = "systems";
        inputs = {
          inherit
            base
            users
            workloads
            disko
            nixpkgs
            home-manager
            stylix
            ;
        };
      };
      hardware = lib.mkStage ./04-hardware {
        name = "hardware";
        inputs = {
          inherit nixos-hardware;
        };
      };
      patches = import ./99-patches;
      config = lib.mkStage ./config {
        name = "config";
        inputs = {
          inherit
            patches
            base
            users
            systems
            fira-code
            nil
            sops-nix
            nix-vscode-extensions
            nixos-wsl
            yoloproj
            determinate
            ;

          nixpkgs = nixpkgs;
          nixos-hardware = hardware.outputs;
        };
      };
    in
    config.outputs
    // {
      flakeModules = nixpkgs.lib.mergeAttrsList [
        base.outputs.flakeModules
        users.outputs.flakeModules
        systems.outputs.flakeModules
      ];
      nixosModules = nixpkgs.lib.mergeAttrsList [
        base.outputs.nixosModules
        users.outputs.nixosModules
        config.outputs.nixosModules
        {
          hardware = hardware.outputs.nixosModules;
          disko = {
            imports = [ disko.nixosModules.disko ];
          };
          sops = {
            imports = [ sops-nix.nixosModules.sops ];
          };
        }
      ];
      lib = nixpkgs.lib.mergeAttrsList [
        workloads.outputs.lib
      ];
      overlays = {
        default = patches;
      };
    };
}
