{ lib, pkgs, system, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkOptionDefault mkIf mkDefault types;
  inherit (import ./_lib.nix { inherit lib; })
    mkDependentEnableOption mkUsageOption;
  cfg = config.usage.chat;
in {
  options.usage.chat = mkUsageOption "chat" ({ config, ... }: {
    options = {
      programs.element = {
        enable = mkDependentEnableOption "element" config.enable;
      };

      programs.signal = {
        enable = mkDependentEnableOption "signal" config.enable;
      };

      programs.slack = {
        enable = mkDependentEnableOption "slack" config.enable;
      };
    };
  });

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      lib.optional cfg.programs.element.enable element-desktop
      ++ lib.optional cfg.programs.signal.enable signal-desktop
      ++ lib.optional (cfg.programs.slack.enable && system == "x86_64-linux")
      slack;
  };
}
