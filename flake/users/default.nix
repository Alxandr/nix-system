{ lib, flake-parts-lib, config, ... }:
let
  inherit (lib) mkOption types;
  inherit (flake-parts-lib) mkSubmoduleOptions;
  inherit (config.flake) nixosModules;
in
{
  imports = [ ../vendor/home-manager ];

  options.flake = mkSubmoduleOptions {
    users = mkOption {
      type = types.lazyAttrsOf types.deferredModule;
      default = { };
    };
  };

  config.flake.lib.mkUser = name: module: args@{ config, ... }:
    let
      user = config.users.users.${name};
      group = config.users.groups.${name};
      argsModule = {
        config._module.args = args // { inherit user group; };
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
          home-manager.users.${name} = userDefModule.config.home;
        };
      };
    in
    {
      imports = [ defaultsModule userModule ];
    };

  config.flake.nixosModules.users = {
    _file = ./default.nix;

    imports = [
      nixosModules.home-manager
    ];

    config = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };
  };
}
