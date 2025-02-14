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

  cfg = config.workloads.gaming;
in
{
  options.workloads.gaming = mkWorkloadOption {
    name = "gaming";
    defaultEnable = config.workloads.desktop.enable;
    programs = mergeAttrsList (
      [
        {
          parsec = mkProgramOption {
            inherit pkgs;
            name = "Parsec";
            package = "parsec-bin";
          };

          moonlight-qt = mkProgramOption {
            inherit pkgs;
            name = "Moonlight-Qt";
            package = "moonlight-qt";
          };

          gamemode = mkProgramOption {
            inherit pkgs;
            name = "GameMode";
          };
        }
      ]
      ++ optional (system == "x86_64-linux") {
        steam = mkProgramOption {
          inherit pkgs;
          name = "Steam";
          package = "steam";

          module.options = {
            protonGe = mkProgramOption {
              inherit pkgs;
              name = "Proton GE";
              package = "proton-ge-bin";
            };

            remotePlay.openFirewall = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Open ports in the firewall for Steam Remote Play.
              '';
            };

            dedicatedServer.openFirewall = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Open ports in the firewall for Source Dedicated Server.
              '';
            };

            localNetworkGameTransfers.openFirewall = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Open ports in the firewall for Steam Local Network Game Transfers.
              '';
            };

            gamescopeSession = {
              enable = mkEnableOption "GameScope Session" // {
                default = true;
              };
              args = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  Arguments to be passed to GameScope for the session.
                '';
              };

              env = mkOption {
                type = types.attrsOf types.str;
                default = { };
                description = ''
                  Environmental variables to be passed to GameScope for the session.
                '';
              };
            };

            extest.enable = mkEnableOption ''
              Load the extest library into Steam, to translate X11 input events to
              uinput events (e.g. for using Steam Input on Wayland)
            '';

            protontricks = mkProgramOption {
              inherit pkgs;
              name = "Protontricks";
              package = "protontricks";
              defaultEnable = true;
            };
          };
        };
      }
    );
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.programs.parsec.enable) {
      environment.systemPackages = [ cfg.programs.parsec.package ];
    })
    (mkIf (cfg.programs.moonlight-qt.enable) {
      environment.systemPackages = [ cfg.programs.moonlight-qt.package ];
    })
    (mkIf (cfg.programs.gamemode.enable) {
      programs.gamemode.enable = true;
    })
    (mkIf (system == "x86_64-linux" && cfg.programs.steam.enable) {
      programs.steam = {
        enable = true;
        package = cfg.programs.steam.package;
        remotePlay.openFirewall = cfg.programs.steam.remotePlay.openFirewall;
        dedicatedServer.openFirewall = cfg.programs.steam.dedicatedServer.openFirewall;
        localNetworkGameTransfers.openFirewall = cfg.programs.steam.localNetworkGameTransfers.openFirewall;
        gamescopeSession = {
          enable = cfg.programs.steam.gamescopeSession.enable;
          args = cfg.programs.steam.gamescopeSession.args;
          env = cfg.programs.steam.gamescopeSession.env;
        };
        extest.enable = cfg.programs.steam.extest.enable;
        protontricks = {
          enable = cfg.programs.steam.protontricks.enable;
          package = cfg.programs.steam.protontricks.package;
        };
        extraCompatPackages = [
          (mkIf cfg.programs.steam.protonGe.enable cfg.programs.steam.protonGe.package)
        ];
        fontPackages = [
          pkgs.liberation_ttf
          pkgs.wqy_zenhei
          pkgs.source-han-sans
        ];
        extraPackages = [
          pkgs.gamemode
        ];
      };
    })
  ]);
}
