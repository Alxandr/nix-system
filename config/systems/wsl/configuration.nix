{
  lib,
  config,
  pkgs,
  nixos-wsl,
  determinate,
  ...
}:
{
  imports = [
    nixos-wsl.default
    determinate.default
    ./windows-proxies.nix
    ./dev-env.nix
  ];

  sops.secrets."altinn.env" = {
    mode = "0440";
    group = config.users.groups.keys.name;
    sopsFile = ../../../secrets/wsl/altinn.env;
    format = "dotenv";
  };

  workloads.development.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.podman.dockerCompat = false;
  users.extraGroups.docker.members = [ "alxandr" ];

  # Secrets manager
  services.gnome.gnome-keyring.enable = true;

  # Disable netbird - it makes little sense in WSL
  services.netbird.enable = false;

  # WSL specific
  wsl.enable = true;
  wsl.defaultUser = "alxandr";
  wsl.ssh-agent.enable = true;
  wsl.interop.register = true;

  wsl.extraBin = [
    # Required by VS Code's Remote WSL extension
    { src = "${pkgs.coreutils}/bin/dirname"; }
    { src = "${pkgs.coreutils}/bin/readlink"; }
    { src = "${pkgs.coreutils}/bin/uname"; }
  ];

  # Enable pulseaudio (works with WSLg)
  services.pulseaudio.enable = true;

  # Setup Netbird client for WSL
  services.netbird.clients.wtnetbird = {
    # Port used to listen to wireguard connections
    port = 51821;

    # Set this to true if you want the GUI client
    ui.enable = false;

    # This opens ports required for direct connection without a relay
    openFirewall = true;

    # This opens necessary firewall ports in the Netbird client's network interface
    openInternalFirewall = true;
  };

  environment.systemPackages = with pkgs; [ netbird ];

  # Required by VS Code's Remote WSL extension
  programs.nix-ld.enable = true;

  environment.variables.PATH = lib.mkForce [
    config.environment.sessionVariables.PATH
    "$PATH"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
