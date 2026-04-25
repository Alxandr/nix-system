{
  pkgs,
  config,
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
    services.tailscale.enable = true;

    # Sunshine game streaming
    services.sunshine.enable = true;
    services.sunshine.openFirewall = true;
    services.sunshine.capSysAdmin = true;
    services.sunshine.autoStart = true;

    # Enable iscsi
    services.openiscsi.enable = true;
    services.openiscsi.name = "iqn.2026-03.me.alxandr:${config.networking.hostName}";

    # Workloads
    workloads.desktop.enable = true;
    workloads.desktop.environment.plasma.enable = true;
    workloads.desktop.environment.hyprland.enable = true;
    workloads.desktop.environment.niri.enable = true;
    workloads.gaming.enable = true;
    workloads.development.enable = true;

    environment.systemPackages = with pkgs; [
      mcp-proxy
      openiscsi
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
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
