{
  config,
  lib,
  pkgs,
  nixos-hardware,
  ...
}:
{
  imports = [
    nixos-hardware.common-cpu-amd
    nixos-hardware.common-cpu-amd-pstate
    nixos-hardware.common-gpu-amd
    nixos-hardware.common-pc-ssd
  ];

  # 6.14 and above have good GPU support
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linux.version "6.14") (
    lib.mkDefault pkgs.linuxPackages_latest
  );
}
