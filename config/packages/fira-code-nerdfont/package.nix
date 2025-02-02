{
  stdenvNoCC,
  pkgs,
  fira-code,
}:

let
  inherit (pkgs) nerd-font-patcher;
  fira-code-ttf = fira-code.override {
    useVariableFont = false;
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fira-code-nerdfont";
  version = fira-code.version;
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir src
    mkdir out

    cp ${fira-code-ttf}/share/fonts/truetype/*.ttf src
    for font in src/*.ttf; do
      ${nerd-font-patcher}/bin/nerd-font-patcher \
        -out out \
        --no-progressbars \
        --complete \
        --variable-width-glyphs \
        --quiet \
        $font

      ${nerd-font-patcher}/bin/nerd-font-patcher \
        -out out \
        --no-progressbars \
        --complete \
        --quiet \
        $font
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/truetype out/*.ttf

    runHook postInstall
  '';
})
