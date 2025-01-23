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

  cfg = config.workloads.chat;
in
{
  options.workloads.chat = mkWorkloadOption {
    name = "chat";
    defaultEnable = config.workloads.desktop.enable;
    programs = mergeAttrsList (
      [
        {
          element = mkProgramOption {
            inherit pkgs;
            name = "Element";
            package = "element-desktop";
          };

          signal = mkProgramOption {
            inherit pkgs;
            name = "Signal";
            package = "signal-desktop";
          };
        }
      ]
      ++ optional (system == "x86_64-linux") {
        discord = mkProgramOption {
          inherit pkgs;
          name = "Discord";
          package = "discord";
        };

        slack = mkProgramOption {
          inherit pkgs;
          name = "Slack";
          package = "slack";
        };
      }
    );
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.programs.element.enable {
      environment.systemPackages = [ cfg.programs.element.package ];
    })
    (mkIf cfg.programs.signal.enable {
      environment.systemPackages = [ cfg.programs.signal.package ];
    })
    (mkIf (system == "x86_64-linux" && cfg.programs.discord.enable) {
      environment.systemPackages = [ cfg.programs.discord.package ];
    })
    (mkIf (system == "x86_64-linux" && cfg.programs.slack.enable) {
      environment.systemPackages = [ cfg.programs.slack.package ];
    })
  ]);
}
