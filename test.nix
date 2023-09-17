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

  config.perSystem.nixosTemplates.server = { system, ... }:
    let
      inherit (config.flake) nixosModules diskoConfigurations;
    in
    {
      imports = [
        nixosModules.disko
        nixosModules.diskoKeys
      ];

      config.disko = diskoConfigurations.test.disko;
      config.system.stateVersion = "23.05";
    };
}
