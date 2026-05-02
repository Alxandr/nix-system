{ pkgs, packages }:
pkgs.mkShell {
  packages = with pkgs; [
    codex
    just
    nix-tree
    nodejs_24
    sops
    ssh-to-age
    typescript
    openssl
    libsecret
  ];

  shellHook = ''
    mkdir -p node_modules
  '';
}
