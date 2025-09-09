{
  pkgs,
  ...
}:
{
  imports = [
    ./samba.nix
  ];

  config = {
    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable networking
    networking.networkmanager.enable = true;

    # Workloads
    workloads.desktop.enable = true;
    workloads.desktop.environment.plasma.enable = true;
    workloads.desktop.environment.niri.enable = true;
    workloads.gaming.enable = true;

    # XBox Controller
    hardware.xone.enable = true;

    # Some packages
    environment.systemPackages = with pkgs; [
      unzip
      cabextract
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
