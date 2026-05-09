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

    packages.hf2nix

    # development of hf2nix
    basedpyright
    python3Packages.ruff
    python3Packages.huggingface-hub
  ];

  shellHook = ''
    mkdir -p node_modules
  '';
}
