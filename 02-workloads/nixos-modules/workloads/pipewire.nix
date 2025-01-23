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

  cfg = config.workloads.pipewire;
in
{
  options.workloads.pipewire = mkWorkloadOption {
    name = "pipewire";
    defaultEnable = config.workloads.desktop.enable;
    programs = mergeAttrsList [ ];
    module.options = { };
  };

  config = mkIf cfg.enable {
    # rtkit is optional but recommended
    security.rtkit.enable = true;

    services.pulseaudio.enable = false;
    services.pipewire = {
      enable = true;
      audio.enable = true; # true anyways
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber.enable = true;
    };

    environment.etc."/pipewire/pipewire.conf.d/pipewire.conf".text = ''
      default.clock.quantum = 2048 #1024
      default.clock.min-quantum = 1024 #32
      default.clock.max-quantum = 4096 #2048
    '';
  };
}
