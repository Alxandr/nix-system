{
  lib,
  name,
  pkgs,
  osConfig,
  ...
}:

with lib;

let
  cfg = osConfig.users;

  userOpts =
    { config, ... }:
    {
      options = {
        name = mkOption {
          type = types.passwdEntry types.str;
          default = name;
          apply =
            x:
            assert (
              stringLength x < 32 || abort "Username '${x}' is longer than 31 characters which is not allowed!"
            );
            x;
          description = ''
            The name of the user account. If undefined, the name of the
            attribute set will be used.
          '';
        };

        description = mkOption {
          type = types.passwdEntry types.str;
          default = "";
          example = "Alice Q. User";
          description = ''
            A short description of the user account, typically the
            user's full name.  This is actually the “GECOS” or “comment”
            field in {file}`/etc/passwd`.
          '';
        };

        isNormalUser = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Indicates whether this is an account for a “real” user.
            This automatically sets {option}`group` to `users`,
            {option}`createHome` to `true`,
            {option}`home` to {file}`/home/«username»`,
            {option}`useDefaultShell` to `true`,
            and {option}`isSystemUser` to `false`.
            Exactly one of `isNormalUser` and `isSystemUser` must be true.
          '';
        };

        group = mkOption {
          type = types.str;
          apply =
            x:
            assert (
              stringLength x < 32 || abort "Group name '${x}' is longer than 31 characters which is not allowed!"
            );
            x;
          default = config.name;
          description = "The user's primary group.";
        };

        extraGroups = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "The user's auxiliary groups.";
        };

        shell = mkOption {
          type = types.nullOr (types.either types.shellPackage (types.passwdEntry types.path));
          default =
            if config.isNormalUser && config.useDefaultShell then cfg.defaultUserShell else pkgs.shadow;
          defaultText = literalExpression "pkgs.shadow";
          example = literalExpression "pkgs.bashInteractive";
          description = ''
            The path to the user's shell. Can use shell derivations,
            like `pkgs.bashInteractive`. Don’t
            forget to enable your shell in
            `programs` if necessary,
            like `programs.zsh.enable = true;`.
          '';
        };

        useDefaultShell = mkOption {
          type = types.bool;
          default = config.isNormalUser;
          description = ''
            If true, the user's shell will be set to
            {option}`users.defaultUserShell`.
          '';
        };

        packages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          example = literalExpression "[ pkgs.firefox pkgs.thunderbird ]";
          description = ''
            The set of packages that should be made available to the user.
            This is in contrast to {option}`environment.systemPackages`,
            which adds packages to all users.
          '';
        };

        openssh.authorizedKeys = {
          keys = mkOption {
            type = lib.types.listOf types.singleLineStr;
            default = [ ];
            description = ''
              A list of verbatim OpenSSH public keys that should be added to the
              user's authorized keys. The keys are added to a file that the SSH
              daemon reads in addition to the the user's authorized_keys file.
              You can combine the `keys` and
              `keyFiles` options.
              Warning: If you are using `NixOps` then don't use this
              option since it will replace the key required for deployment via ssh.
            '';
            example = [
              "ssh-rsa AAAAB3NzaC1yc2etc/etc/etcjwrsh8e596z6J0l7 example@host"
              "ssh-ed25519 AAAAC3NzaCetcetera/etceteraJZMfk3QPfQ foo@bar"
            ];
          };
        };
      };

      config = mkMerge [
        (mkIf config.isNormalUser {
          extraGroups = [ "users" ];
        })
      ];
    };
in

{
  options.user = mkOption {
    type = types.submodule userOpts;
    default = { };
  };

  # config.user.extraGroups = [ "users" ];

  # config.user = {
  #   isNormalUser = mkDefault true;
  #   name = mkDefault name;
  #   group = mkDefault config.user.name;
  # };
}
