{
  workloads-lib,
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  inherit (workloads-lib) mkDefaultsOption;
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.defaults.locale;
in
{
  options.defaults.locale = mkDefaultsOption {
    name = "locale";
  };

  config = mkIf cfg.enable ({
    # Set your time zone.
    time.timeZone = lib.mkDefault "Europe/Oslo";

    # Select internationalisation properties.
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = lib.mkDefault "nb_NO.UTF-8";
      LC_IDENTIFICATION = lib.mkDefault "nb_NO.UTF-8";
      LC_MEASUREMENT = lib.mkDefault "nb_NO.UTF-8";
      LC_MONETARY = lib.mkDefault "nb_NO.UTF-8";
      LC_NAME = lib.mkDefault "nb_NO.UTF-8";
      LC_NUMERIC = lib.mkDefault "nb_NO.UTF-8";
      LC_PAPER = lib.mkDefault "nb_NO.UTF-8";
      LC_TELEPHONE = lib.mkDefault "nb_NO.UTF-8";
      LC_TIME = lib.mkDefault "nb_NO.UTF-8";
    };

    # Configure console
    console = {
      earlySetup = true;
      keyMap = lib.mkDefault "eurkey";
      useXkbConfig = lib.mkDefault true;
    };
  });
}
