{ lib, pkgs, system, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkOptionDefault mkIf mkDefault types;
  inherit (import ./_lib.nix { inherit lib; })
    mkDependentEnableOption mkUsageOption;
  cfg = config.usage.wine;
in {
  options.usage.wine = mkUsageOption "wine" ({ config, ... }: {
    options = {
      programs.winetricks = {
        enable = mkDependentEnableOption "winetricks" config.enable;
      };

      programs.q4wine = {
        enable = mkDependentEnableOption "q4wine" config.enable;
      };
    };
  });

  config = mkIf (cfg.enable && system == "x86_64-linux") {
    environment.systemPackages = with pkgs;
      [ wineWowPackages.full ]
      ++ lib.optional cfg.programs.winetricks.enable winetricks
      ++ lib.optional cfg.programs.q4wine.enable q4wine;
  };
}
