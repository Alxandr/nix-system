{ config, inputs, ... }:
let
  # ESP partition (EFI boot)
  esp_partition = {
    label = "EFI";
    name = "ESP";
    size = "512M";
    type = "EF00";
    content = {
      type = "filesystem";
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [
        "defaults"
      ];
    };
  };

  # BTRFS content (subvolume layout)
  btrfs_content = {
    type = "btrfs";
    extraArgs = [ "-f" ]; # Override existing partition
    subvolumes = {
      # Subvolume name is different from mountpoint
      "@root" = {
        mountpoint = "/";
      };
      "@home" = {
        mountpoint = "/home";
        mountOptions = [ "compress=zstd" ];
      };
      "@nix" = {
        mountpoint = "/nix";
        mountOptions = [ "compress=zstd" "noatime" ];
      };
      "@swap" = {
        mountpoint = "/.swapvol";
        swap.enable = true;
        swap.size = "8G";
      };
    };
  };

  # Luks encrypted partition
  luks_partition = {
    name = "luks";
    size = "100%";
    content = {
      type = "luks";
      name = "crypted";
      extraOpenArgs = [ "--allow-discards" ];
      # if you want to use the key for interactive login be sure there is no trailing newline
      # for example use `echo -n "password" > /tmp/secret.key`
      settings.keyFile = config.flake.diskoConfigurations.test.disko.keys.root.path;
      content = btrfs_content;
    };
  };

in
{
  config.flake.diskoConfigurations.test.disko = {
    keys = {
      root = {
        interactive = false;
      };
    };
    devices = {
      disk = {
        root = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
              ESP = esp_partition;
              luks = luks_partition;
            };
          };
        };
      };
    };
  };

  config.perSystem.nixosTemplates.server = { system, modulesPath, lib, pkgs, ... }:
    let
      inherit (config.flake) nixosModules diskoConfigurations;
    in
    {
      _file = ./test.nix;

      imports = [
        (modulesPath + "/profiles/qemu-guest.nix")
        nixosModules.disko
        nixosModules.diskoKeys
      ];

      config = {
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

        disko = diskoConfigurations.test.disko;
        system.stateVersion = "23.05";
      };
    };
}
