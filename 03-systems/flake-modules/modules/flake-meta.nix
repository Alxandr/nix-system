{ name, path }:
{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.meta.flake;
  programs = config.programs;
in
{
  options = {
    meta = {
      flake = {
        path = mkOption {
          type = types.nonEmptyStr;
          default = path;
        };

        configKey = mkOption {
          type = types.nonEmptyStr;
          default = name;
        };

        configSpecifier = mkOption {
          type = types.nonEmptyStr;
          default = "${cfg.path}#${cfg.configKey}";
        };
      };
    };

    programs.update-system = {
      enable = mkEnableOption "update-system script" // {
        default = true;
      };

      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ../packages/update-system.nix {
          flakeMeta = cfg;
        };
      };
    };
  };

  config = {
    networking.hostName = mkDefault cfg.configKey;
    system.autoUpgrade.flake = mkDefault cfg.configSpecifier;
    environment.systemPackages = optional programs.update-system.enable programs.update-system.package;
  };
}
