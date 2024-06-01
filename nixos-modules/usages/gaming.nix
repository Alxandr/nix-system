{ lib, pkgs, system, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkOptionDefault mkIf mkDefault types;
  inherit (import ./_lib.nix { inherit lib; })
    mkDependentEnableOption mkUsageOption;
  cfg = config.usage.gaming;
in {
  options.usage.gaming = mkUsageOption "gaming" ({ config, ... }: {
    options.programs.steam = {
      enable = mkDependentEnableOption "steam" config.enable;
    };
  });

  config = mkIf cfg.enable {
    programs.steam =
      mkIf (system == "x86_64-linux" && cfg.programs.steam.enable) {
        enable = mkDefault true;
        protontricks.enable = mkDefault true;
      };

    usage.wine.enable = mkDefault true;
  };
}
