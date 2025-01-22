{ ... }:
{ lib, pkgs, ... }:
{
  config = {
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

    # Configure console keymap
    console.keyMap = lib.mkDefault "no";

    # Environment variables
    environment.sessionVariables = {
      # XDG Variables
      XDG_CACHE_HOME = lib.mkDefault "$HOME/.cache";
      XDG_CONFIG_HOME = lib.mkDefault "$HOME/.config";
      XDG_DATA_HOME = lib.mkDefault "$HOME/.local/share";
      XDG_STATE_HOME = lib.mkDefault "$HOME/.local/state";

      # Not officially in the XDG specification
      XDG_BIN_HOME = lib.mkDefault "$HOME/.local/bin";
      PATH = [ "$XDG_BIN_HOME" ];
    };

    # Setup GPG
    programs.gnupg.agent.enable = true;

    # Programs for all systems
    environment.systemPackages = with pkgs; [
      btop
      htop
      zoxide
      eza
    ];

    nix.settings = {
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
}
