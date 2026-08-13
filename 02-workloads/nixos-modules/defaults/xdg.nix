{ lib, config, ... }: {
  options = {
    xdg.directories.bin-home = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "$HOME/.local/bin/";
      description = "Value of `$XDG_BIN_HOME` environment variable";
    };
  };

  config = {
    xdg.directories.enable = lib.mkDefault true;

    environment.sessionVariables = lib.mkIf config.xdg.directories.enable {
      XDG_BIN_HOME = config.xdg.directories.bin-home;

      PATH = [ config.xdg.directories.bin-home ];
    };
  };
}
