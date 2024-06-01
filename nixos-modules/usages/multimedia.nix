{ lib, pkgs, system, config, ... }:
let
  inherit (lib) mkOption mkEnableOption mkOptionDefault mkIf mkDefault types;
  inherit (import ./_lib.nix { inherit lib; })
    mkDependentEnableOption mkUsageOption;
  cfg = config.usage.multimedia;
in {
  options.usage.multimedia = mkUsageOption "multimedia" ({ config, ... }: {
    options = {
      programs.vlc = { enable = mkDependentEnableOption "vlc" config.enable; };

      programs.jellyfin = {
        enable = mkDependentEnableOption "jellyfin" config.enable;
      };

      programs.spotify = {
        enable = mkDependentEnableOption "spotify" config.enable;
      };
    };
  });

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      lib.optional cfg.programs.vlc.enable vlc
      ++ lib.optional cfg.programs.jellyfin.enable jellyfin-media-player
      ++ lib.optional (cfg.programs.spotify.enable && system == "x86_64-linux")
      spotify;
  };
}
