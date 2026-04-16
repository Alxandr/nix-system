{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkOption types mkIf;

  cfg = config.home.sessionVariableFiles;

in
{
  options.home.sessionVariableFiles = mkOption {
    type = types.listOf types.path;
    default = [ ];
    description = ''
      List of files containing environment variables to be loaded into the
      session. Each file should be in the format of a dotenv file, i.e. each
      line should be in the format `KEY=VALUE`. Lines starting with `#` are
      treated as comments and ignored.

      These files are loaded in order, so if the same variable is defined in
      multiple files, the value from the last file will take precedence.

      This option is useful for loading secrets from files managed by sops-nix,
      as it allows you to keep secrets out of your shell configuration and only
      load them when needed.
    '';

    example = ''
      home.sessionVariableFiles = [
        config.sops.secrets."my-secret-variables".path
        config.sops.secrets."another-secret".path
      ];
    '';
  };

  config.home.sessionVariablesExtra =
    let
      sourceLines = lib.map (file: ". ${lib.escapeShellArg file}") cfg;
      source = lib.concatStringsSep "\n" sourceLines;

    in
    mkIf (cfg != [ ]) ''
      # BEGIN sessionVariablesExtra
      set -a # automatically export all variables defined in this block
      ${source}
      set +a # disable automatic export after this block
      # END sessionVariablesExtra
    '';
}
