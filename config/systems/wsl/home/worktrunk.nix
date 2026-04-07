{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    mkPackageOption
    mkIf
    mkAfter
    getExe
    ;

  cfg = config.programs.worktrunk;

  tomlFormat = pkgs.formats.toml { };

in
{
  options.programs.worktrunk = {
    enable = mkEnableOption "worktrunk, the worktree manager";

    package = mkPackageOption pkgs "worktrunk" { };

    config = mkOption {
      inherit (tomlFormat) type;
      default = { };

      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/worktrunk/config.toml`.

        See https://worktrunk.dev/ for documentation.
      '';
    };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };

    enableNushellIntegration = lib.hm.shell.mkNushellIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    programs = {
      bash.initExtra = mkIf cfg.enableBashIntegration (
        # Using `mkAfter` to make it more likely to appear after other
        # manipulations of the prompt.
        mkAfter ''
          eval "$(${getExe cfg.package} config shell init bash)"
        ''
      );

      fish.interactiveShellInit = mkIf cfg.enableFishIntegration (
        # Using `mkAfter` to make it more likely to appear after other
        # manipulations of the prompt.
        mkAfter ''
          ${getExe cfg.package} config shell init fish | source
        ''
      );

      zsh.initContent = mkIf cfg.enableZshIntegration ''
        eval "$(${getExe cfg.package} config shell init zsh)"
      '';

      nushell.extraConfig = mkIf cfg.enableNushellIntegration (mkAfter ''
        ${getExe cfg.package} config shell init nu | save -f ($nu.default-config-dir | path join vendor/autoload/wt.nu)
      '');
    };

    xdg.configFile."worktrunk/config.toml" = mkIf (cfg.config != { }) {
      source = tomlFormat.generate "worktrunk-config" cfg.config;
    };
  };
}
