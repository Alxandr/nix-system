{ lib, flake-parts-lib, config, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
  inherit (config.flake) nixosModules;
in {
  options.users = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    default = { };
  };

  options.flake = mkSubmoduleOptions {
    users = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };
  };

  config = let
    userConfigModule = {
      options = {
        trusted = mkOption {
          type = types.bool;
          default = false;
        };

        _1password = mkOption {
          type = types.bool;
          default = true;
        };

        user = mkOption {
          type = types.submodule {
            options = {
              packages = mkOption {
                type = types.listOf types.package;
                default = [ ];
              };

              extraGroups = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };
            };
          };
        };

        home = mkOption { type = types.deferredModule; };
      };
    };

    getUserNixosModuleList = userName: userModule: {
      name = userName;
      value = args@{ config, pkgs, system, lib, ... }:
        let
          host = config;
          user = config.users.users.${userName};
          group = config.users.groups.${userName};
          argsModule = {
            config._module.args = args // {
              inherit user group host pkgs system lib;
            };
          };
          userDefModule = lib.evalModules {
            modules = [ argsModule userConfigModule userModule ];
          };

          defaultsModule = {
            config.users.groups.${userName} = { };
            config.users.users.${userName} = {
              isNormalUser = true;
              group = userName;
              extraGroups = [ "users" ];
            };
          };

          generatedModule = {
            config = {
              nix.settings.trusted-users =
                lib.mkIf userDefModule.config.trusted [ userName ];
              programs._1password-gui.polkitPolicyOwners =
                lib.mkIf userDefModule.config._1password [ userName ];
              users.users.${userName} = userDefModule.config.user;
              home-manager.users.${userName} = {
                imports = [ argsModule userDefModule.config.home ];
              };
            };
          };
        in { imports = [ defaultsModule generatedModule ]; };
    };
    userModules = lib.mapAttrsToList getUserNixosModuleList config.users;
  in { flake.users = lib.listToAttrs userModules; };
}
