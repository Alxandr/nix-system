# flake module
{ lib, flake-parts-lib, inputs, ... }:
let
  inherit (inputs) disko;
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  diskoLib = disko.lib.lib;

  diskoRootType = types.submoduleWith {
    modules = [{
      options = {
        devices = mkOption {
          type = diskoLib.toplevel;
        };
      };

      # config._module.args = {};
    }];
  };

  diskoConfigurationType = types.submoduleWith {
    modules = [{
      options = {
        disko = mkOption {
          type = diskoRootType;
        };
      };
    }];
  };
in
{
  options.flake = mkSubmoduleOptions {
    diskoConfigurations = mkOption {
      type = types.attrsOf diskoConfigurationType;
      # default = { };
    };
  };

  config.flake.nixosModules.disko = disko.nixosModules.disko;
}
