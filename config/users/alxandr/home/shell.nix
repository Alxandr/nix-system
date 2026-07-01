{
  pkgs,
  lib,
  osConfig,
  ...
}:

with lib;

let
  isDesktop = osConfig.workloads.desktop.enable;
  sharedShell = [
    (builtins.readFile ./functions.sh)
  ];

in

{
  programs.zoxide.enable = true;
  programs.starship.enable = true;
  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;

  programs.atuin = {
    enable = true;
    daemon.enable = true;
    #flags = [ "--disable-up-arrow" ];
    settings = {
      workspaces = true;
      search_mode = "daemon-fuzzy";
      filter_mode_shell_up_key_binding = "session-preload";
    };
  };

  home.packages = with pkgs; [
    dua
  ];

  home.shellAliases = {
    # Add color to commands
    grep = "grep --color=auto";

    # Protect against overwriting
    cp = "cp -i";
    mv = "mv -i";

    # cd to git root directory
    cdg = "cd \"$(git root)\"";

    # Mirror stdout to stderr, useful for seeing data going through a pipe
    peek = "tee >(cat 1>&2)";

    # Bat
    cat = "bat --style=plain --paging=never";
    catmore = "bat --style=plain --paging=always";

    # eza
    ls = "eza";
    ll = "eza -lh";
    tree = "eza --tree";

    # zoxide
    zz = "z -";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;

    initContent = lib.strings.concatLines sharedShell;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;

    initExtra = lib.strings.concatLines sharedShell;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  xdg.configFile."direnv/lib/hm-op-direnv.sh".source =
    "${pkgs.nur.repos.Alxandr.op-direnv}/share/op-direnv/direnvrc";
}
