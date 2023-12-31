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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";


    # Format disks with nix-config
    # https://github.com/nix-community/disko
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Manage a user environment using Nix
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
  };

  outputs =
    { self
    , nixpkgs
    , disko
    , home-manager
    , flake-utils
    , neovim-flake
    , ...
    }:
    let
      flake = "github:Alxandr/nix-system";
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      host-lib = import ./lib {
        inherit neovim-flake home-manager nixpkgs disko;
        inherit (nixpkgs) lib;
      };

    in
    {
      lib = host-lib;
    }
    //
    host-lib.mkSystem {
      inherit flake supportedSystems;
      hosts = {
        dbost = ./hosts/servers/dbost;
      };
    };
}
