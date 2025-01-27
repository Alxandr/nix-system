{
  workloads-lib,
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  inherit (workloads-lib) mkWorkloadOption mkProgramOption;
  inherit (pkgs) system;

  associationOptions =
    with types;
    attrsOf (coercedTo (either (listOf str) str) (x: lib.concatStringsSep ";" (lib.toList x)) str);

  cfg = config.workloads.wayland;
in
{
  options.workloads.wayland = mkWorkloadOption {
    name = "wayland";
    defaultEnable = config.workloads.desktop.enable;
    programs = mergeAttrsList [
      {
        xdg-utils = mkProgramOption {
          inherit pkgs;
          name = "XDG Utils";
          package = "xdg-utils";
        };

        wayland-utils = mkProgramOption {
          inherit pkgs;
          name = "Wayland Utils";
          package = "wayland-utils";
        };

        xwayland = mkProgramOption {
          inherit pkgs;
          name = "XWayland";
          package = "xwayland";
        };
      }
    ];
    module.options = {
      xdg.portal = {
        enable =
          mkEnableOption ''[xdg desktop integration](https://github.com/flatpak/xdg-desktop-portal)''
          // {
            default = true;
          };

        extraPortals = {
          kde = mkProgramOption {
            inherit pkgs;
            name = "KDE Portal";
            package = "xdg-desktop-portal-kde";
            defaultEnable = false;
          };

          gtk = mkProgramOption {
            inherit pkgs;
            name = "GTK Portal";
            package = "xdg-desktop-portal-gtk";
            defaultEnable = false;
          };

          wlr = mkProgramOption {
            inherit pkgs;
            name = "WLR Portal";
            package = "xdg-desktop-portal-wlr";
            defaultEnable = true;
          };

          hyprland = mkProgramOption {
            inherit pkgs;
            name = "Hyprland Portal";
            package = "xdg-desktop-portal-hyprland";
            defaultEnable = false;
          };
        };

        xdgOpenUsePortal = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Sets environment variable `NIXOS_XDG_OPEN_USE_PORTAL` to `1`
            This will make `xdg-open` use the portal to open programs, which resolves bugs involving
            programs opening inside FHS envs or with unexpected env vars set from wrappers.
            See [#160923](https://github.com/NixOS/nixpkgs/issues/160923) for more info.
          '';
        };

        config = mkOption {
          type = types.attrsOf associationOptions;
          default = {

          };
          example = {
            x-cinnamon = {
              default = [
                "xapp"
                "gtk"
              ];
            };
            pantheon = {
              default = [
                "pantheon"
                "gtk"
              ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            };
            common = {
              default = [ "gtk" ];
            };
          };
          description = ''
            Sets which portal backend should be used to provide the implementation
            for the requested interface. For details check {manpage}`portals.conf(5)`.

            Configs will be linked to `/etc/xdg/xdg-desktop-portal/` with the name `$desktop-portals.conf`
            for `xdg.portal.config.$desktop` and `portals.conf` for `xdg.portal.config.common`
            as an exception.
          '';
        };

        configPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          example = lib.literalExpression "[ pkgs.gnome-session ]";
          description = ''
            List of packages that provide XDG desktop portal configuration, usually in
            the form of `share/xdg-desktop-portal/$desktop-portals.conf`.

            Note that configs in `xdg.portal.config` will be preferred if set.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      environment.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1"; # for VSCode Discord etc
      };
    }
    (mkIf cfg.programs.xdg-utils.enable {
      environment.systemPackages = [ cfg.programs.xdg-utils.package ];
    })
    (mkIf cfg.programs.wayland-utils.enable {
      environment.systemPackages = [ cfg.programs.wayland-utils.package ];
    })
    (mkIf cfg.programs.xwayland.enable {
      environment.systemPackages = [ cfg.programs.xwayland.package ];
    })
    (mkIf cfg.xdg.portal.enable {
      xdg.portal.enable = true;
      xdg.portal.xdgOpenUsePortal = cfg.xdg.portal.xdgOpenUsePortal;
      xdg.portal.config = mkMerge [
        {
          common = {
            default = [ "wlr" ];
          };
        }
        cfg.xdg.portal.config
      ];
      xdg.portal.configPackages = cfg.xdg.portal.configPackages;
    })
    (mkIf (cfg.xdg.portal.enable && cfg.xdg.portal.extraPortals.kde.enable) {
      xdg.portal.extraPortals = [ cfg.xdg.portal.extraPortals.kde.package ];
    })
    (mkIf (cfg.xdg.portal.enable && cfg.xdg.portal.extraPortals.gtk.enable) {
      xdg.portal.extraPortals = [ cfg.xdg.portal.extraPortals.gtk.package ];
    })
    (mkIf (cfg.xdg.portal.enable && cfg.xdg.portal.extraPortals.wlr.enable) {
      xdg.portal.extraPortals = [ cfg.xdg.portal.extraPortals.wlr.package ];
    })
    (mkIf (cfg.xdg.portal.enable && cfg.xdg.portal.extraPortals.hyprland.enable) {
      xdg.portal.extraPortals = [ cfg.xdg.portal.extraPortals.hyprland.package ];
    })
  ]);
}
