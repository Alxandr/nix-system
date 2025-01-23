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
  inherit (pkgs) system;

  cfg = config.defaults.shell;
in
{
  options.defaults.shell = mkDefaultsOption {
    name = "shell";
  };

  config = mkIf cfg.enable ({
    # set the default shell to zsh
    programs.zsh.enable = lib.mkDefault true;
    # nixos uses mkDefault to set the default shell to bash
    # - this overrides that while still keeping the priority low
    users.defaultUserShell = lib.mkOverride (1000 - 1) pkgs.zsh;
  });
}
