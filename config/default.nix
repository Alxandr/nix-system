{ inputs, config, ... }:
let
  inherit (inputs)
    base
    users
    systems
    fira-code
    ;
  inherit (config.flake) diskoConfigurations;
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
      { pkgs, ... }:
      rec {
        packages = {
          inherit (pkgs) cascadia-code;
          fira-code = pkgs.callPackage ./packages/fira-code/package.nix { src = fira-code; };
        };

        apps = {
          nh.program = "${packages.nh}/bin/nh";
        };
      };

    systemConfigurations.sharedModules = [
      (
        { pkgs, alxandrPackages, ... }:
        {
          config._module.args.alxandrPackages = config.flake.packages.${pkgs.system};
          config.fonts.packages = [
            pkgs.cascadia-code
            alxandrPackages.fira-code
          ];
        }
      )
      ./theme
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
