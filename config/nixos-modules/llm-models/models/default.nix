{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  mkModel =
    path:
    let
      model = import path;
      files = lib.map (
        file:
        fetchurl {
          inherit (file) url hash;
          passthru = {
            inherit (file) path;
          };
        }
      ) model.files;

      installLines = lib.lists.concatMap (file: [
        ''mkdir -p $(dirname $out/"${file.path}")''
        ''ln -s "${file}" $out/"${file.path}"''
      ]) files;
    in
    stdenvNoCC.mkDerivation {
      pname = "${model.owner}/${model.repo}:${model.quant}";
      version = model.rev;

      dontUnpack = true;
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        ${lib.strings.concatLines installLines}

        runHook postInstall
      '';

      passthru.model = {
        inherit (model) owner repo quant;
      };

      meta = {
        mainModel = model.model;
      }
      // lib.optionalAttrs (model.mmproj or null != null) {
        mmproj = model.mmproj;
      };
    };

  processDir =
    base-path:
    lib.mapAttrs' (
      name: type:
      let
        path = "${base-path}/${name}";
      in
      if type == "directory" then
        {
          inherit name;
          value = processDir path (builtins.readDir path);
        }
      else
        {
          name = lib.strings.removeSuffix ".nix" name;
          value = mkModel path;
        }
    );

  all = processDir ./. (removeAttrs (builtins.readDir ./.) [ "default.nix" ]);
in
all
