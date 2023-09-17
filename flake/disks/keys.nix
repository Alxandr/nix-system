# flake module
{ lib, flake-parts-lib, inputs, ... }:
let
  inherit (inputs) disko;
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  diskoLib = disko.lib.lib;

  keyFileType = types.submoduleWith {
    modules = [
      ({ name, config, ... }: {
        options = {
          description = lib.mkOption {
            type = types.str;
            default =
              if config.interactive
              then "Encryption password '${name}'"
              else "Encryption key '${name}'";
          };

          path = lib.mkOption {
            type = types.str;
            default =
              if config.interactive
              then "/tmp/disk-encryption-passwords/${name}.key"
              else "/etc/disk-encryption-keys/${name}.key";
          };

          interactive = lib.mkOption {
            type = types.bool;
            default = true;
            description = "Wheather or not this is an interactive key (only saved during install and later prompted for)";
          };
        };
      })
    ];
  };

  diskoRootType = types.submoduleWith {
    modules = [{
      options = {
        keys = mkOption {
          type = types.attrsOf keyFileType;
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

  diskoKeysModule = { lib, ... }: {
    options.disko.keys = lib.mkOption {
      type = types.attrsOf keyFileType;
      default = { };
    };
  };
in
{
  imports = [
    ../vendor/disko
  ];

  options.flake = mkSubmoduleOptions {
    diskoConfigurations = mkOption {
      type = types.attrsOf diskoConfigurationType;
    };
  };

  config.flake.nixosModules.diskoKeys = diskoKeysModule;
}
