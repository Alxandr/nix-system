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

  cfg = config.workloads.desktop.environment.plasma;
in
{
  options.workloads.desktop.environment.plasma = mkDesktopEnvironmentOption {
    name = "Plasma";
  };

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [ kwallet-pam ];

    workloads.wayland.xdg.portal.extraPortals.kde.enable = true;
    workloads.wayland.xdg.portal.config.kde = {
      default = [
        "kde"
        "wlr"
      ];
    };
  };
}
