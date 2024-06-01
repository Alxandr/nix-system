{ lib, pkgs, system, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkOptionDefault mkIf mkDefault types;
  inherit (import ./_lib.nix { inherit lib; })
    mkDependentEnableOption mkUsageOption;
  cfg = config.usage.desktop;
in {
  options.usage.desktop = mkUsageOption "desktop" ({ config, ... }: {
    options = {
      programs._1password = {
        enable = mkDependentEnableOption "1password" config.enable;
      };
    };
  });

  config = mkIf cfg.enable {
    usage.chat.enable = mkDefault true;
    usage.multimedia.enable = mkDefault true;

    programs._1password.enable = mkDefault cfg.programs._1password.enable;
    programs._1password-gui = {
      enable = mkDefault cfg.programs._1password.enable;
    };
  };
}
