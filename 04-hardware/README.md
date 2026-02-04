# 04-hardware

This stage provides a sub-flake that re-exports the upstream `nixos-hardware` flake with custom hardware module amendments for devices that have not been added upstream.

## Structure

- `default.nix` - The main flake module that re-exports all `nixos-hardware` modules plus custom hardware modules
- `nixos-modules/` - Directory containing custom hardware modules

## Custom Hardware Modules

### Minisforum MS-S1 Max

Hardware configuration for the Minisforum MS-S1 Max mini PC. This module is based on the Framework Desktop configuration from nixos-hardware, as the hardware is very similar.

**Usage:**

In your system's `hardware.nix`:

```nix
{
  nixos-hardware,
  ...
}:
{
  imports = [
    nixos-hardware.minisforum-ms-s1-max
  ];
  
  # Additional system-specific hardware configuration...
}
```

**Features:**
- AMD CPU support with P-State driver
- AMD GPU support with kernel 6.14+ optimization
- SSD optimization (TRIM)

## Adding New Hardware Modules

To add a new hardware module:

1. Create a new `.nix` file in `nixos-modules/` with the device name (e.g., `manufacturer-model.nix`)
2. Follow the pattern of existing modules (see `minisforum-ms-s1-max.nix` as an example)
3. Import appropriate common modules from `nixos-hardware` (e.g., `common-cpu-intel`, `common-gpu-amd`, etc.)
4. Add device-specific kernel modules and hardware settings
5. Export the module in `default.nix` by adding it to the `nixosModules` attribute set

## Pattern Reference

Hardware modules should follow this general pattern:

```nix
{
  config,
  lib,
  pkgs,
  nixos-hardware,
  ...
}:
{
  # Import common hardware profiles
  imports = [
    nixos-hardware.common-cpu-intel  # or common-cpu-amd
    nixos-hardware.common-gpu-intel  # or common-gpu-amd
    nixos-hardware.common-pc-ssd     # if applicable
  ];

  # Device-specific kernel modules
  boot.initrd.availableKernelModules = [ /* ... */ ];
  boot.kernelModules = [ /* ... */ ];
  
  # Hardware enablement
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.graphics.enable = lib.mkDefault true;
  
  # Optional: Bluetooth, firmware updates, etc.
  hardware.bluetooth.enable = lib.mkDefault true;
  services.fwupd.enable = lib.mkDefault true;
}
```

This pattern is based on the upstream `nixos-hardware` Framework Desktop module structure.
