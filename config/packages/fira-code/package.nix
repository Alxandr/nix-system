{
  src,
  pkgs,
  useVariableFont ? true,
}:

if useVariableFont then
  pkgs.callPackage ./vf.nix { src = src; }
else
  pkgs.callPackage ./ttf.nix { src = src; }
