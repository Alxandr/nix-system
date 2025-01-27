{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (inputs)
    base
    users
    systems
    fira-code
    ags
    nil
    ;
  inherit (config.flake) diskoConfigurations;
  inherit (config.flake) nixosModules;
in
{
  imports = [
    base.flakeModules.flake-path
    base.flakeModules.home-manager
    base.flakeModules.disko
    users.flakeModules.user-manager
    systems.flakeModules.systems
    ./disko-configurations
  ];

  config = {
    # debug = true;

    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    flake.path = "github:Alxandr/nix-system";

    perSystem =
      { pkgs, inputs', ... }:
      rec {
        packages = {
          inherit (pkgs) cascadia-code;
          inherit (inputs'.nil.packages) nil;
          ags = inputs'.ags.packages.ags // {
            full = inputs'.ags.packages.agsFull;
            inherit (inputs'.ags.packages)
              hyprland
              battery
              bluetooth
              mpris
              network
              powerprofiles
              tray
              wireplumber
              ;
          };
          fira-code = pkgs.callPackage ./packages/fira-code/package.nix { src = fira-code; };
        };

        apps = {
          nh.program = "${pkgs.nh}/bin/nh";
        };

        devShells.default = pkgs.mkShell {
          packages = [
            (packages.ags.override {
              extraPackages = with packages.ags; [
                hyprland
                battery
                bluetooth
                mpris
                network
                powerprofiles
                tray
                wireplumber
                pkgs.gtk-layer-shell
              ];
            })
          ];
        };
      };

    flake.nixosModules = {
      keyboard = ./nixos-modules/keyboard;
    };

    systemConfigurations.sharedModules = [
      (
        { pkgs, ... }:
        {
          config.nixpkgs.overlays = [
            (final: prev: {
              inherit (config.flake.packages.${pkgs.system}) fira-code ags nil;
            })
          ];

          config.fonts.packages = [
            pkgs.cascadia-code
            pkgs.fira-code
          ];
        }
      )
      ./theme
      nixosModules.keyboard
    ];

    systemConfigurations.systems.tv = {
      unstable = true;
      hardware = ./systems/tv/hardware.nix;
      configuration = ./systems/tv/configuration.nix;
      users = {
        alxandr = ./users/alxandr;
      };
      drives = {
        imports = [ diskoConfigurations.btrfs ];
        disko.devices.disk.root.device = "/dev/nvme0n1";
        disko.swap.root = {
          enable = true;
          size = "32G";
        };
      };
    };

    systemConfigurations.systems.laptop = {
      unstable = true;
      hardware = ./systems/laptop/hardware.nix;
      configuration = ./systems/laptop/configuration.nix;
      users = {
        alxandr = ./users/alxandr;
      };
      drives = {
        imports = [ diskoConfigurations.luks-btrfs ];
        disko.devices.disk.root.device = "/dev/nvme0n1";
        disko.swap.root = {
          enable = true;
          size = "32G";
        };
      };
    };
  };
}
