{ nixosModules, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  flakeMeta = config.meta.flake;
  cfg = config.system.update-command;
in
{
  # imports = [ nixosModules.flake-meta ];

  options.system.update-command = mkOption {
    type = types.submodule (
      { ... }:
      {
        options = {
          enable = mkEnableOption "update-command";

          package = mkOption {
            type = types.package;
            default = pkgs.callPackage ./update-system.nix {
              inherit flakeMeta;
              # nixos-rebuild = config.system.build.nixos-rebuild;
            };
          };
        };
      }
    );

    default = { };
  };

  config.environment.systemPackages = mkIf cfg.enable [ cfg.package ];
}
