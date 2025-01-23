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

  cfg = config.workloads.wine;
in
{
  options.workloads.wine = mkWorkloadOption {
    name = "wine";
    defaultEnable = config.workloads.desktop.enable;
    programs = mergeAttrsList (
      optional (system == "x86_64-linux") {
        winetricks = mkProgramOption {
          inherit pkgs;
          name = "Winetricks";
          package = "winetricks";
        };

        q4wine = mkProgramOption {
          inherit pkgs;
          name = "Q4Wine";
          package = "q4wine";
        };
      }
    );
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (system == "x86_64-linux" && cfg.programs.winetricks.enable) {
      environment.systemPackages = [ cfg.programs.winetricks.package ];
    })
    (mkIf (system == "x86_64-linux" && cfg.programs.q4wine.enable) {
      environment.systemPackages = [ cfg.programs.q4wine.package ];
    })
  ]);
}
