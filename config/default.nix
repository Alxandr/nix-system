{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (inputs)
    patches
    base
    users
    systems
    hardware
    fira-code
    sops-nix
    nix-vscode-extensions
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
    systems.flakeModules.install
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
          fira-code = pkgs.callPackage ./packages/fira-code/package.nix { src = fira-code; };
          fira-code-nerdfont = pkgs.callPackage ./packages/fira-code-nerdfont/package.nix {
            inherit (packages) fira-code;
            # fira-code = pkgs.callPackage ./packages/fira-code/package.nix {
            #   src = fira-code;
            #   useVariableFont = false;
            # };
          };
        };

        apps = {
          nh.program = pkgs.nh;
          nh.meta.description = "NixOS helper";
        };

        devShells.default = import ./dev-shell.nix { inherit pkgs packages; };
      };

    flake.nixosModules = {
      keyboard = ./nixos-modules/keyboard;
    };

    systemConfigurations.extraSpecialArgs = {
      nixos-hardware = hardware.nixosModules;
    };

    systemConfigurations.sharedModules = [
      (
        { pkgs, ... }:
        {
          config.nixpkgs.overlays = [
            patches
            nix-vscode-extensions.overlays.default
            (final: prev: {
              inherit (config.flake.packages.${pkgs.stdenv.hostPlatform.system})
                fira-code
                fira-code-nerdfont
                nil
                ;
            })
          ];

          config.fonts.packages = [
            pkgs.cascadia-code
            pkgs.fira-code
            pkgs.fira-code-nerdfont
            pkgs.fira-code-symbols

            # Chinese, Korean, and Japanese fonts
            pkgs.noto-fonts-cjk-sans
            pkgs.noto-fonts-cjk-serif
          ];
        }
      )
      ./theme
      ./nixos-modules/certificates
      nixosModules.keyboard
      sops-nix.nixosModules.sops
      (
        { config, pkgs, ... }:
        {
          config.sops = {
            defaultSopsFile = ../secrets/secrets.yaml;
            age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
            secrets = {
              "nix/access-tokens" = {
                mode = "0440";
                group = config.users.groups.keys.name;
              };
            };
          };

          config.nix.extraOptions = ''
            !include ${config.sops.secrets."nix/access-tokens".path}
          '';
        }
      )
      (
        { ... }:
        {
          nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ];
        }
      )
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
