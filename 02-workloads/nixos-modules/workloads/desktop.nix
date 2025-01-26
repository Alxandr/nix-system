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

  cfg = config.workloads.desktop;
in
{
  imports = [ ./desktop-environments/all.nix ];

  options.workloads.desktop = mkWorkloadOption {
    name = "desktop";
    programs = {
      _1password = mkProgramOption {
        inherit pkgs;
        name = "1Password CLI";
        package = "_1password-cli";
      };

      _1password-gui = mkProgramOption {
        inherit pkgs;
        name = "1Password GUI";
        package = "_1password-gui";
      };

      brave = mkProgramOption {
        inherit pkgs;
        name = "Brave Browser";
        package = "brave";
      };

      peazip = mkProgramOption {
        inherit pkgs;
        name = "PeaZip";
        package = "peazip";
      };

      libva-utils = mkProgramOption {
        inherit pkgs;
        name = "libva-utils";
        package = "libva-utils";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.programs._1password.enable {
      programs._1password.enable = true;
      programs._1password.package = cfg.programs._1password.package;
    })
    (mkIf cfg.programs._1password.enable {
      programs._1password-gui.enable = true;
      programs._1password-gui.package = cfg.programs._1password-gui.package;
    })
    (mkIf cfg.programs.brave.enable {
      environment.systemPackages = [ cfg.programs.brave.package ];
    })
    (mkIf cfg.programs.peazip.enable {
      environment.systemPackages = [ cfg.programs.peazip.package ];
    })
    (mkIf cfg.programs.libva-utils.enable {
      environment.systemPackages = [ cfg.programs.libva-utils.package ];
    })
  ]);
}
