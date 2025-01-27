{
  workloads-lib,
  lib,
  config,
  ...
}:

with lib;

let
  inherit (workloads-lib) mkDesktopEnvironmentOption;

  cfg = config.workloads.desktop.environment.hyprland;
in
{
  options.workloads.desktop.environment.hyprland = mkDesktopEnvironmentOption {
    name = "Hyprland";
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
  };
}
