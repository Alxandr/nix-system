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
      "https://ags.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # Secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Format disks with nix-config
    # https://github.com/nix-community/disko
    disko = {
      url = "github:nix-community/disko/v1.6.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stylix = {
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix-unstable = {
      url = "github:lordkekz/stylix?ref=f61debdb5cd8eb4df55fca8f344a1b6884291b20";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };

    # Widgets (bar and similar)
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Nix language server
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # # modern window compositor
    # hyprland.url = "github:hyprwm/Hyprland/v0.27.0";
    # # community wayland nixpkgs
    # nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Fira Code source
    fira-code = {
      url = "github:tonsky/FiraCode/master";
      flake = false;
    };
  };

  outputs =
    {
      flake-parts,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      disko,
      home-manager,
      home-manager-unstable,
      stylix,
      stylix-unstable,
      fira-code,
      ags,
      nil,
      nixos-hardware,
      nix-vscode-extensions,
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
            nixpkgs-unstable
            home-manager
            home-manager-unstable
            stylix
            stylix-unstable
            ;
        };
      };
      config = lib.mkStage ./config {
        name = "config";
        inputs = {
          inherit
            base
            users
            systems
            fira-code
            ags
            nil
            sops-nix
            nixos-hardware
            nix-vscode-extensions
            ;

          nixpkgs = nixpkgs;
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
          inherit (disko.nixosModules) disko;
        }
      ];
      lib = nixpkgs.lib.mergeAttrsList [
        workloads.outputs.lib
      ];
    };
}
