{ lib, flake-parts-lib, config, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
  inherit (config.flake) nixosModules;
in
{
  options.flake = mkSubmoduleOptions {
    userConfigurations = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };

    userModules = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };
  };

  config.flake.lib.mkUser = name: module: args@{ config, ... }:
    let
      host = config;
      user = config.users.users.${name};
      group = config.users.groups.${name};
      argsModule = {
        config._module.args = args // { inherit user group host; };
      };
      userDefModule = lib.evalModules {
        modules = [ argsModule ./user-modules.nix module ];
      };

      defaultsModule = {
        config.users.groups.${name} = { };
        config.users.users.${name} = {
          isNormalUser = true;
          group = name;
          extraGroups = [ "users" ];
          passwordFile = "/etc/nixos/users/${name}/password";
        };
      };

      userModule = {
        config = {
          users.users.${name} = userDefModule.config.user;
          home-manager.users.${name} = {
            imports = [
              argsModule
              userDefModule.config.home
            ];
          };
        };
      };
    in
    {
      imports = [ defaultsModule userModule ];
    };
}
