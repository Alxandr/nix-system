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

  cfg = config.workloads.development;
in
{
  options.workloads.development = mkWorkloadOption {
    name = "development";
    defaultEnable = false;
    programs = mergeAttrsList ([
      {
        dive = mkProgramOption {
          inherit pkgs;
          name = "dive";
          package = "dive";
        };

        just = mkProgramOption {
          inherit pkgs;
          name = "just";
          package = "just";
        };

        jq = mkProgramOption {
          inherit pkgs;
          name = "jq";
          package = "jq";
        };

        yq = mkProgramOption {
          inherit pkgs;
          name = "yq";
          package = "yq-go";
        };

        codex = mkProgramOption {
          inherit pkgs;
          name = "codex";
          package = "codex";
        };

        bun = mkProgramOption {
          inherit pkgs;
          name = "bun";
          package = "bun";
        };

        nodejs = mkProgramOption {
          inherit pkgs;
          name = "nodejs";
          package = "nodejs";
        };
      }
    ]);
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Enable common container config files in /etc/containers
      virtualisation.containers.enable = true;
      virtualisation = {
        podman = {
          enable = true;

          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = mkDefault true;

          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
      };
    }
    (mkIf cfg.programs.dive.enable {
      environment.systemPackages = [ cfg.programs.dive.package ];
    })
    (mkIf cfg.programs.just.enable {
      environment.systemPackages = [ cfg.programs.just.package ];
    })
    (mkIf cfg.programs.jq.enable {
      environment.systemPackages = [ cfg.programs.jq.package ];
    })
    (mkIf cfg.programs.yq.enable {
      environment.systemPackages = [ cfg.programs.yq.package ];
    })
    (mkIf cfg.programs.codex.enable {
      environment.systemPackages = [ cfg.programs.codex.package ];
    })
    (mkIf cfg.programs.bun.enable {
      environment.systemPackages = [ cfg.programs.bun.package ];
    })
    (mkIf cfg.programs.nodejs.enable {
      environment.systemPackages = [ cfg.programs.nodejs.package ];
    })
  ]);
}
