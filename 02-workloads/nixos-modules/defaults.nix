{ lib, pkgs, ... }:
{
  imports = [
    ./lib-module.nix
    ./defaults/all.nix
  ];

  config = {
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

    programs.vim.enable = true;

    programs.neovim.enable = true;
    programs.neovim.defaultEditor = true;

    # Programs for all systems
    environment.systemPackages = with pkgs; [
      btop
      dig
      htop
      tcpdump
      traceroute
      wget
    ];

    nix.settings = {
      # enable flakes globally
      experimental-features = [
        "nix-command"
        "flakes"
        "recursive-nix"
        "pipe-operators"
      ];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = lib.mkDefault true;
  };
}
