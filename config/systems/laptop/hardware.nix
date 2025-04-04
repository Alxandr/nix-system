{
  lib,
  config,
  nixos-hardware,
  ...
}:
{
  imports = [
    nixos-hardware.lenovo-thinkpad-z13-gen1
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
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
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.graphics = {
    enable = lib.mkDefault true;
  };

  hardware.amdgpu.amdvlk = {
    enable = lib.mkDefault true;
    support32Bit.enable = lib.mkDefault true;
  };

  hardware.bluetooth.enable = lib.mkDefault true;
}
