{ lib, ... }:
{
  config.virtualisation.containers.registries.settings.unqualified-search-registries = lib.mkDefault [ "docker.io" ];
}
