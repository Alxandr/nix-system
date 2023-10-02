{ inputs, ... }:
{ lib, pkgs, config, ... }:
with lib;
let
  inherit (pkgs) system;
  inherit (inputs.neovim-flake.packages.${system}.nix) extendConfiguration;
  cfg = config.programs.neovim-ide;
in
{
  options.programs.neovim-ide = {
    enable = mkEnableOption "NeoVim IDE";
    settings = mkOption {
      type = types.deferredModule;
      default = {
        _file = ./neovim.nix;
      };
    };

    package = mkOption {
      type = types.raw;
      default = extendConfiguration {
        modules = [ cfg.settings ];
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];
  };
}
