{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  esp = import ./partitions/esp.nix { };
  btrfs = import ./partitions/btrfs.nix {
    inherit lib;
    config.swap = config.disko.swap.root;
  };
in
{
  options.disko.swap = mkOption {
    type = types.submodule {
      options.root = mkOption {
        type = types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = false;
            };

            size = mkOption { type = types.str; };
          };
        };
        default = { };
      };
    };
    default = { };
  };

  config.disko = {
    devices = {
      disk = {
        root = {
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
              ESP = esp;
              root = btrfs;
            };
          };
        };
      };
    };
  };
}
