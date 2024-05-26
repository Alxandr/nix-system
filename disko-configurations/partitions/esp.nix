{ ... }: {
  label = "EFI";
  name = "ESP";
  size = "512M";
  type = "EF00";
  content = {
    type = "filesystem";
    format = "vfat";
    mountpoint = "/boot";
    mountOptions = [ "defaults" "umask=0077" ];
  };
}
