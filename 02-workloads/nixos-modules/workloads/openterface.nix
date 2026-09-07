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

  cfg = config.workloads.openterface;
in
{
  options.workloads.openterface = mkWorkloadOption {
    name = "openterface";
    defaultEnable = false;
    programs = mergeAttrsList ([
      {
        openterface = mkProgramOption {
          inherit pkgs;
          name = "openterface";
          package = "openterface-qt";
        };
      }
    ]);
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.programs.openterface.enable {
      environment.systemPackages = [ cfg.programs.openterface.package ];

      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
        SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
        SUBSYSTEM=="ttyUSB", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
      '';
    })
  ]);
}
