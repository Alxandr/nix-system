{ lib, ... }:

with lib;

{
  mkWorkloadOption =
    {
      name,
      programs,
      module ? null,
      defaultEnable ? false,
    }:
    let
      defaultModule = {
        options.enable = mkOption {
          default = defaultEnable;
          example = !defaultEnable;
          description = "Whether to enable ${name} workload.";
          type = types.bool;
        };

        options.programs = programs;
      };
      modules =
        if module == null then
          [ defaultModule ]
        else
          [
            defaultModule
            module
          ];

      type = types.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = modules;
      };

    in
    mkOption {
      type = type;
      default = { };
      description = "Workload ${name}";
    };

  mkDefaultsOption =
    {
      name,
      # programs,
      module ? null,
      defaultEnable ? true,
    }:
    let
      defaultModule = {
        options.enable = mkOption {
          default = defaultEnable;
          example = !defaultEnable;
          description = "Whether to enable ${name} defaults.";
          type = types.bool;
        };

        # options.programs = programs;
      };
      modules =
        if module == null then
          [ defaultModule ]
        else
          [
            defaultModule
            module
          ];

      type = types.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = modules;
      };

    in
    mkOption {
      type = type;
      default = { };
      description = "${name} defaults";
    };

  mkDesktopEnvironmentOption =
    {
      name,
      module ? null,
      defaultEnable ? false,
    }:
    let
      defaultModule = {
        options.enable = mkOption {
          default = defaultEnable;
          example = !defaultEnable;
          description = "Whether to enable the ${name} desktop environment.";
          type = types.bool;
        };
      };
      modules =
        if module == null then
          [ defaultModule ]
        else
          [
            defaultModule
            module
          ];

      type = types.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = modules;
      };

    in
    mkOption {
      type = type;
      default = { };
      description = "${name} Desktop Environment";
    };

  mkProgramOption =
    {
      name,
      package ? null,
      pkgs,
      defaultEnable ? true,
      module ? null,
    }:

    let
      defaultModule = {
        options.enable = mkOption {
          default = defaultEnable;
          example = !defaultEnable;
          description = "Whether to enable ${name}.";
          type = types.bool;
        };
      };
      modules =
        [ defaultModule ]
        ++ optionals (package != null) [
          {
            options.package = mkPackageOption pkgs name {
              default = package;
            };
          }
        ]
        ++ optionals (module != null) [ module ];

      type = types.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = modules;
      };

    in
    mkOption {
      type = type;
      default = { };
      description = "Program ${name}";
    };
}
