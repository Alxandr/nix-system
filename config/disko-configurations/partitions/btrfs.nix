{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  size = "100%";
  content = {
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
        mountOptions = [
          "compress=zstd"
          "noatime"
        ];
      };
      "@swap" = lib.mkIf config.swap.enable {
        mountpoint = "/.swapvol";
        swap.swapfile.size = config.swap.size;
      };
    };
  };
}
