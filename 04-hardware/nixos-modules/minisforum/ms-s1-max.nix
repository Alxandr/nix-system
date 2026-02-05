{
  nixos-hardware,
  ...
}:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    nixos-hardware.common-cpu-amd
    nixos-hardware.common-cpu-amd-pstate
    nixos-hardware.common-gpu-amd
    nixos-hardware.common-pc-ssd
  ];

  # 6.18 is required for network drivers
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.18") (
    lib.mkDefault pkgs.linuxPackages_latest
  );
}
