{ lib, ... }:
let importConfiguration = loc: lib.setDefaultModuleLocation loc (import loc);
in { flake.diskoConfigurations = { btrfs = importConfiguration ./btrfs.nix; }; }
