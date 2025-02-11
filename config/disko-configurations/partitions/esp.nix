{ ... }:
{
  label = "EFI";
  name = "ESP";
  size = "5G";
  type = "EF00";
  content = {
    type = "filesystem";
    format = "vfat";
    mountpoint = "/boot";
    mountOptions = [
      "defaults"
      "umask=0077"
    ];
  };
}
