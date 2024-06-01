{ lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;

  mkDependentEnableOption = name: default:
    mkOption {
      default = default;
      example = true;
      description = "Whether to enable ${name}.";
      type = lib.types.bool;
    };

  mkUsageOption = name: module:
    let
      commonModule = {
        options.enable = mkEnableOption name;
        options.programs = mkOption {
          default = { };
          type = types.submoduleWith { modules = [ ]; };
        };
      };
    in mkOption {
      default = { };
      type = types.submoduleWith { modules = [ commonModule module ]; };
    };

in { inherit mkDependentEnableOption mkUsageOption; }
