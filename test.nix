{ config, inputs, ... }:
{
  config.perSystem.nixosTemplates.server = { system, modulesPath, lib, pkgs, ... }:
    let
      inherit (config.flake) nixosModules diskoConfigurations;
    in
    {
      _file = ./test.nix;

      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        nixosModules.disks
        diskoConfigurations.root-btrfs
        nixosModules.users
        (config.flake.lib.mkUser "alxandr" config.flake.users.alxandr)
      ];

      config = {
        # makes local testing better
        virtualisation.virtualbox.guest.enable = true;
        virtualisation.virtualbox.guest.x11 = true;

        disko.devices.disk.root.device = "/dev/sda";
        disko.keys.root.interactive = false;

        boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_pci" "virtio_scsi" "usbhid" "sr_mod" ];
        boot.initrd.kernelModules = [ ];
        boot.kernelModules = [ ];
        boot.extraModulePackages = [ ];

        networking.hostName = "test-server";
        # Use the systemd-boot EFI boot loader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Pick only one of the below networking options.
        # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
        networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
        networking.firewall.enable = true;

        # Set your time zone.
        time.timeZone = lib.mkDefault "Europe/Oslo";

        # Setup users
        users.mutableUsers = false;

        # Select internationalisation properties.
        i18n.defaultLocale = "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = "nb_NO.UTF-8";
          LC_IDENTIFICATION = "nb_NO.UTF-8";
          LC_MEASUREMENT = "nb_NO.UTF-8";
          LC_MONETARY = "nb_NO.UTF-8";
          LC_NAME = "nb_NO.UTF-8";
          LC_NUMERIC = "nb_NO.UTF-8";
          LC_PAPER = "nb_NO.UTF-8";
          LC_TELEPHONE = "nb_NO.UTF-8";
          LC_TIME = "nb_NO.UTF-8";
        };

        # Configure console keymap
        console.keyMap = "no";

        # Enable the OpenSSH daemon.
        services.openssh = {
          enable = true;
          settings = {
            X11Forwarding = true;
            PermitRootLogin = "no"; # disable root login
            PasswordAuthentication = false; # disable password login
          };
          openFirewall = true;
        };

        # globally installed packages (for all users)
        environment.systemPackages = with pkgs; [
          wget
          curl
          bash
          git
        ];

        # Environment variables
        environment.sessionVariables = rec {
          # XDG Variables
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_STATE_HOME = "$HOME/.local/state";

          # Not officially in the XDG specification
          XDG_BIN_HOME = "$HOME/.local/bin";
          PATH = [
            "${XDG_BIN_HOME}"
          ];
        };

        # do garbage collection weekly to keep disk usage low
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 1w";
        };

        # Manual optimise storage: nix-store --optimise
        # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
        nix.settings.auto-optimise-store = true;

        # enable flakes globally
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;

        system.stateVersion = "23.05";
      };
    };
}
