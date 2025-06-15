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

  cfg = config.workloads.desktop.environment.niri;
in
{
  options.workloads.desktop.environment.niri = mkDesktopEnvironmentOption {
    name = "niri";
  };

  config = mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
      configPackages = lib.mkDefault [ pkgs.niri ];
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        niri = {
          prettyName = "niri";
          comment = "niri compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/niri";
        };
      };
    };

    security = {
      polkit.enable = true;
      pam.services.swaylock = { };

      pam.services = {
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
    };

    programs = {
      dconf.enable = lib.mkDefault true;
    };

    services.graphical-desktop.enable = true;

    environment.systemPackages = with pkgs; [
      niri

      libsForQt5.kwalletmanager
      libsForQt5.kwallet-pam
      libsForQt5.kwallet

      kdePackages.kwalletmanager
      kdePackages.kwallet-pam
      kdePackages.kwallet
    ];
  };
}
