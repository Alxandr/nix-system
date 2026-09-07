final: prev: {
  openterface-qt =
    if prev.lib.versionOlder prev.openterface-qt.version "0.5.30" then
      prev.openterface-qt.overrideAttrs (_: {
        version = "0.5.30";
        src = prev.fetchFromGitHub {
          owner = "TechxArtisanStudio";
          repo = "Openterface_QT";
          tag = "0.5.30";
          hash = "sha256-7ZgdAEQXy9QS7hRzrHOQEuimllRQ4w+u1/3DWXB3jUc=";
        };
      })
    else
      prev.openterface-qt;

  # netbird = prev.callPackage ./netbird.nix { };
}
