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
    ragenix
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
            inherit (inputs.ags) lib;
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
          fira-code-nerdfont = pkgs.callPackage ./packages/fira-code-nerdfont/package.nix {
            inherit (packages) fira-code;
            # fira-code = pkgs.callPackage ./packages/fira-code/package.nix {
            #   src = fira-code;
            #   useVariableFont = false;
            # };
          };
          # alxandr-bar = pkgs.callPackage ./packages/bar/package.nix { inherit (packages) ags; };
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
              inherit (config.flake.packages.${pkgs.system})
                fira-code
                fira-code-nerdfont
                ags
                nil
                ;

              # # https://github.com/NixOS/nixpkgs/issues/380196
              lldb_14 = prev.lldb_14.overrideAttrs (old: {
                version = "${old.version}-symfix";
                dontCheckForBrokenSymlinks = true;
              });
              lldb = prev.lldb.overrideAttrs (old: {
                version = "${old.version}-symfix";
                dontCheckForBrokenSymlinks = true;
              });
              llvmPackages = prev.llvmPackages // {
                lldb = prev.llvmPackages.lldb.overrideAttrs (old: {
                  version = "${old.version}-symfix";
                  dontCheckForBrokenSymlinks = true;
                });
              };
              llvmPackages_14 = prev.llvmPackages_14 // {
                lldb = prev.llvmPackages_14.lldb.overrideAttrs (old: {
                  version = "${old.version}-symfix";
                  dontCheckForBrokenSymlinks = true;
                });
              };
            })
          ];

          config.fonts.packages = [
            pkgs.cascadia-code
            pkgs.fira-code
            pkgs.fira-code-nerdfont
          ];
        }
      )
      ./theme
      nixosModules.keyboard
      ragenix.nixosModules.default
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
