{ ... }:
{ lib, config, ... }:
with lib;
let
  cfg = config.usage;
  mkDefaultIf = cond: value: mkIf cond (mkDefault value);
in
{
  imports = [ ];
  options = {
    usage = mkOption {
      type = types.submodule ({ config, ... }: {
        options = {
          isServer = mkOption {
            type = types.bool;
            default = false;
          };

          isInteractive = mkOption {
            type = types.bool;
            default = !config.isServer;
          };
        };
      });
      default = { };
    };
  };

  config = {
    # Enable the OpenSSH daemon.
    services.openssh = mkDefaultIf cfg.isServer {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no"; # disable root login
        PasswordAuthentication = false; # disable password login
      };
      openFirewall = true;
    };
  };
}
