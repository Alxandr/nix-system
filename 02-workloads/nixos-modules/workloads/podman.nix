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

  cfg = config.workloads.podman;
in
{
  options.workloads.podman = mkWorkloadOption {
    name = "podman";
    defaultEnable = config.workloads.desktop.enable;
    programs = mergeAttrsList ([
      {
        dive = mkProgramOption {
          inherit pkgs;
          name = "dive";
          package = "dive";
        };
      }
    ]);
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      # Enable common container config files in /etc/containers
      virtualisation.containers.enable = true;
      virtualisation = {
        podman = {
          enable = true;

          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;

          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
      };
    })
    (mkIf cfg.programs.dive.enable {
      environment.systemPackages = [ cfg.programs.dive.package ];
    })
  ]);
}
