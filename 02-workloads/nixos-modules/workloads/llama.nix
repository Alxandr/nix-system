{
  workloads-lib,
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  inherit (workloads-lib) mkWorkloadOption mkProgramOption;
  inherit (pkgs.stdenv.hostPlatform) system;

  cfg = config.workloads.llama;
in
{
  options.workloads.llama = mkWorkloadOption {
    name = "llama";
    defaultEnable = false;
    programs = mergeAttrsList [
      {
        llama-cpp = mkProgramOption {
          inherit pkgs;
          name = "llama-cpp";
          module =
            { config, ... }:
            {
              options = {
                cudaSupport = mkEnableOption "CUDA support" // {
                  default = cfg.cudaSupport;
                };

                rocmSupport = mkEnableOption "ROCm support" // {
                  default = cfg.rocmSupport;
                };

                blasSupport = mkEnableOption "BLAS support" // {
                  default = cfg.blasSupport;
                };

                package = mkOption {
                  type = types.package;
                  default = (
                    pkgs.llama-cpp.override {
                      inherit (config) cudaSupport rocmSupport blasSupport;
                    }
                  );
                };
              };
            };
        };

        llama-swap = mkProgramOption {
          inherit pkgs;
          name = "llama-swap";
          package = "llama-swap";
        };
      }
    ];
    module.options = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 41759;
        description = "Listen port for LLaMA C++ server.";
      };

      cudaSupport = mkEnableOption "CUDA support" // {
        default = pkgs.config.cudaSupport;
      };

      rocmSupport = mkEnableOption "ROCm support" // {
        default = pkgs.config.rocmSupport;
      };

      blasSupport = mkEnableOption "BLAS support" // {
        default = true;
      };

      models = mkOption {
        type = lib.types.lazyAttrsOf lib.types.package;
        default = { };
        description = "LLaMA models to provide to llama-swap.";
      };
    };
  };

  config = mkIf cfg.enable {
    # services.llama-cpp =
    #   mkIf (cfg.programs.llama-cpp.enable && !cfg.programs.llama-cpp.llama-swap.enable)
    #     {
    #       enable = true;
    #       package = cfg.programs.llama-cpp.package;
    #       port = cfg.programs.llama-cpp.port;
    #     };
    services.llama-swap = mkIf cfg.programs.llama-swap.enable (
      let
        llama-server = lib.getExe' cfg.programs.llama-cpp.package "llama-server";
        mkModelConfig =
          model:
          let
            args = [
              "--port"
              "\${PORT}"
              "-ngl"
              "0"
              "--no-webui"
              "-m"
              "${model}/${model.meta.mainModel}"
            ]
            ++ lib.optionals (model.meta.mmproj or null != null) [
              "--mmproj"
              "${model}/${model.meta.mmproj}"
            ];

            cmd = "${llama-server} ${lib.strings.escapeShellArgs args}";
          in
          {
            inherit cmd;
          };
      in
      {
        enable = true;
        port = cfg.port;
        package = cfg.programs.llama-swap.package;
        settings = {
          logLevel = "debug";
          # healthCheckTimeout = 60;
          models = lib.mapAttrs (name: value: mkModelConfig value) cfg.models;
        };
      }
    );
  };
}
