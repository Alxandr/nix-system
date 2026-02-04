{
  config,
  lib,
  pkgs,
  nixos-hardware,
  ...
}:
{
  # Minisforum MS-S1 Max hardware configuration
  # This is a mini PC with AMD Ryzen processors

  imports = [
    nixos-hardware.common-cpu-amd
    nixos-hardware.common-cpu-amd-pstate
    nixos-hardware.common-gpu-amd
    nixos-hardware.common-pc-ssd
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  hardware.graphics = {
    enable = lib.mkDefault true;
  };

  # Bluetooth support for mini PC
  hardware.bluetooth.enable = lib.mkDefault true;

  # Enable firmware updates
  services.fwupd.enable = lib.mkDefault true;
}
