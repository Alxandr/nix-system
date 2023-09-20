{ lib, ... }:
let
  # userOpts = {name, config, ...}: {
  #   options = {

  #   };
  # };
  # mkSubmoduleOption = cfg: mkOption {
  #   type = types.sobmoduleWith { modules = [ cfg ]; };
  # };
in
with lib;
{
  # options.users = mkSubmoduleOption {
  #   installer = mkSubmoduleOption {
  #     setup-password = mkOption {
  #       type = types.bool;
  #       default = true;
  #     };
  #   };
  # };
  # options.users = mkOption {
  #   type = types.submoduleWith {
  #     modules = [{
  #       options.installer = mkOption { };
  #     }];
  #   };
  # };
}
