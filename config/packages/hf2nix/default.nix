{
  lib,
  nix,
  nixfmt,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "hf2nix";
  version = "0.1.0";
  pyproject = false;

  src = ./.;

  propagatedBuildInputs = [
    python3Packages.huggingface-hub
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 hf2nix.py $out/${python3Packages.python.sitePackages}/hf2nix.py
    makeWrapper ${python3Packages.python.interpreter} $out/bin/hf2nix \
      --add-flags $out/${python3Packages.python.sitePackages}/hf2nix.py \
      --prefix PATH : ${
        lib.makeBinPath [
          nix
          nixfmt
        ]
      }

    runHook postInstall
  '';

  meta.mainProgram = "hf2nix";
}
