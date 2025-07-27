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
  inherit (pkgs) kdePackages;

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
    workloads.wayland.xdg.portal.extraPortals.gtk.enable = true;
    workloads.wayland.xdg.portal.config.hyprland = {
      default = [
        "hyprland"
        "kde"
        "gtk"
      ];
    };

    security.pam.services = {
      login.kwallet = {
        enable = true;
        # package = kdePackages.kwallet-pam;
      };
      kde = {
        allowNullPassword = true;
        kwallet = {
          enable = true;
          # package = kdePackages.kwallet-pam;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      libsForQt5.kwalletmanager
      libsForQt5.kwallet-pam
      libsForQt5.kwallet

      kdePackages.kwalletmanager
      kdePackages.kwallet-pam
      kdePackages.kwallet

      grim
    ];
  };
}
