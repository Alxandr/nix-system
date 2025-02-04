{ lib, config, ... }:

with lib;
{
  config = mkIf config.hardware.bluetooth.enable {
    hardware.bluetooth.powerOnBoot = mkDefault true;
    services.blueman.enable = mkDefault true;
  };
}
