{ device, swap, keyFile, encrypted ? true }:

let
  swapvol = if swap == false then { } else {
    "@swap" = {
      mountpoint = "/.swapvol";
    };
  };

  postCreateHook =
    if swap == false then { } else {
      postCreateHook = ''
        (
          MNTPOINT=$(mktemp -d)
          mount /dev/mapper/crypted "$MNTPOINT" -o subvol=/@swap
          trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
          btrfs filesystem mkswapfile --size ${swap} "$MNTPOINT/swapfile"
        )
      '';
    };

  btrfs_content = postCreateHook // {
    type = "btrfs";
    extraArgs = [ "-f" ]; # Override existing partition
    subvolumes = swapvol // {
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
    };
  };

  encrypted_content = {
    type = "luks";
    name = "crypted";
    extraOpenArgs = [ "--allow-discards" ];
    # if you want to use the key for interactive login be sure there is no trailing newline
    # for example use `echo -n "password" > /tmp/secret.key`
    settings.keyFile = keyFile;
    content = btrfs_content;
  };

  content = if encrypted then encrypted_content else btrfs_content;

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

  root_partition = {
    name = "root";
    size = "100%";
    content = content;
  };

  disk = {
    type = "disk";
    device = device;
    content = {
      type = "gpt";
      partitions = {
        ESP = esp_partition;
        root = root_partition;
      };
    };
  };

in
{
  inherit disk;
}
