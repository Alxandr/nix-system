{ pkgs, packages }:
pkgs.mkShell {
  packages = with pkgs; [
    ssh-to-age
    sops
    just
    typescript
    nodejs_24
    nix-tree
  ];

  shellHook = ''
    mkdir -p node_modules
  '';
}
