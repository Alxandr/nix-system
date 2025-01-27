{
  workloads-lib,
  lib,
  config,
  pkgs,
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

    workloads.wayland.xdg.portal.extraPortals.hyprland.enable = true;
    workloads.wayland.xdg.portal.config.hyprland = {
      default = [
        "hyprland"
        "wlr"
      ];
    };

    security.pam.services.kwallet.kwallet.enable = true;
  };
}
