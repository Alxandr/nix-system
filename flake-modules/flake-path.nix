{ lib, ... }:

let inherit (lib) mkOption types;
in { options.flake.path = mkOption { type = types.str; }; }
