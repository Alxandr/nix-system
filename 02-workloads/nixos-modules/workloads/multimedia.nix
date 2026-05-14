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
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.workloads.multimedia;
in
{
  options.workloads.multimedia = mkWorkloadOption {
    name = "multimedia";
    defaultEnable = config.workloads.desktop.enable;
    programs = mergeAttrsList (
      [
        {
          vlc = mkProgramOption {
            inherit pkgs;
            name = "VLC";
            package = "vlc";
          };

          # jellyfin = mkProgramOption {
          #   inherit pkgs;
          #   name = "Jellyfin";
          #   # package = "jellyfin-desktop";
          # };

          tsukimi = mkProgramOption {
            inherit pkgs;
            name = "Tsukimi";
            package = "tsukimi";
          };

          delfin = mkProgramOption {
            inherit pkgs;
            name = "Delfin";
            package = "delfin";
          };
        }
      ]
      ++ optional (system == "x86_64-linux") {
        spotify = mkProgramOption {
          inherit pkgs;
          name = "Spotify";
          package = "spotify";
        };
      }
    );
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.programs.vlc.enable {
      environment.systemPackages = [ cfg.programs.vlc.package ];
    })
    # (mkIf cfg.programs.jellyfin.enable {
    #   environment.systemPackages = [ cfg.programs.jellyfin.package ];
    # })
    (mkIf cfg.programs.tsukimi.enable {
      environment.systemPackages = [ cfg.programs.tsukimi.package ];
    })
    (mkIf cfg.programs.delfin.enable {
      environment.systemPackages = [ cfg.programs.delfin.package ];
    })
    (mkIf (system == "x86_64-linux" && cfg.programs.spotify.enable) {
      environment.systemPackages = [ cfg.programs.spotify.package ];
    })
  ]);
}
