{ lib, pkgs, nixosModules, diskoConfigurations, modulesPath, flake, system, ...
}:
let inherit (lib) mkIf;
in {
  imports = [
    ./hardware.nix
    diskoConfigurations.btrfs
    nixosModules.plasma
    ./samba.nix
  ];

  config = {
    # Disko configuration.
    disko.devices.disk.root.device = "/dev/nvme0n1";
    disko.swap.root = {
      enable = true;
      size = "32G";
    };

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Enable networking
    networking.networkmanager.enable = true;

    # Enable automatic login for the user.
    # services.displayManager.autoLogin.enable = false;
    # services.displayManager.autoLogin.user = "alxandr";

    # Setup auto-upgrade
    system.update-command.enable = true;
    system.autoUpgrade = {
      enable = true;
      operation = "boot";
      dates = "05:00";
      randomizedDelaySec = "45min";
      allowReboot = false;
    };

    # Workloads
    usage.desktop.enable = true;
    usage.gaming.enable = true;

    # wayland support for electron applications
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Some packages
    environment.systemPackages = with pkgs; [ unzip ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
  };
}
