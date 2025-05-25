{ lib, ... }:
{
  config.virtualisation.containers.registries.search = lib.mkDefault [ "docker.io" ];
}
