{ nixosModules, ... }:
{ lib, config, ... }:
with lib;
let
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
  imports = [ ];

  options.disko.keys = lib.mkOption {
    type = types.attrsOf keyFileType;
    default = { };
  };

  config.boot.initrd.secrets =
    let
      allSecrets = lib.mapAttrsToList
        (name: secret: {
          name = secret.path;
          value = secret.path;
          enabled = !secret.interactive;
        })
        config.disko.keys;
      secrets = lib.filter (secret: secret.enabled) allSecrets;
      secretsAttrs = lib.listToAttrs secrets;
    in
    lib.mkIf (builtins.length secrets != 0) secretsAttrs;
}
