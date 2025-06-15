{
  pkgs,
  ...
}:
{
  config = {
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable aarch64 emulation
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

    # Enable networking
    networking.networkmanager.enable = true;

    # Workloads
    workloads.desktop.enable = true;
    workloads.desktop.environment.plasma.enable = true;
    workloads.desktop.environment.hyprland.enable = true;
    workloads.desktop.environment.niri.enable = true;
    workloads.gaming.enable = true;
    workloads.podman.enable = true;

    # Screen configuration in hyprland
    home-manager.sharedModules = [
      {
        wayland.windowManager.hyprland.settings.monitor = [
          "eDP-1, preferred, 0x0, 1.5"
          "desc:Advanced Micro Peripherals Ltd ES07D03 EVE213500529, preferred, auto-left, 1"
        ];
      }
    ];

    # Some packages
    environment.systemPackages = with pkgs; [
      unzip
    ];

    # Setup auto-upgrade
    system.autoUpgrade = {
      enable = true;
      operation = "boot";
      dates = "05:00";
      randomizedDelaySec = "45min";
      allowReboot = false;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
