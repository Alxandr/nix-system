# flake module
{ lib, flake-parts-lib, inputs, config, ... }:
let
  inherit (lib) mkOption types literalExpression;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  # diskoLib = disko.lib.lib;

  # diskoRootType = types.submoduleWith {
  #   modules = [{
  #     options = {
  #       devices = mkOption {
  #         type = diskoLib.toplevel;
  #       };
  #     };

  #     # config._module.args = {};
  #   }];
  # };

  # diskoConfigurationType = types.submoduleWith {
  #   modules = [{
  #     options = {
  #       disko = mkOption {
  #         type = diskoRootType;
  #       };
  #     };
  #   }];
  # };
in
{
  imports = [
    ./keys.nix
  ];

  # # config.flake.fff = disko.lib.diskoScript config.flake.diskoConfigurations.test inputs.nixpkgs.legacyPackages.x86_64-linux;
  # perSystem = { pkgs, ... }: {
  #   # packages.format-test = disko.lib.diskoScript config.flake.diskoConfigurations.test pkgs;
  #   packages = lib.mapAttrs'
  #     (name: config: {
  #       name = "setup-${name}";
  #       value = pkgs.callPackage ./packages/setup-host {
  #         inherit config name;
  #         disko = disko.lib;
  #       }; # disko.lib.diskoScript config pkgs;
  #     })
  #     config.flake.diskoConfigurations;
  # };
}
