{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

with lib;

let
  isDesktop = osConfig.workloads.desktop.enable;
  terminalFont = "Cascadia Code NF";

in
{
  programs.zed-editor = mkIf isDesktop {
    enable = true;
    extensions = [
      "nix"
      "sql"
      "html"
      "toml"
      "crates-lsp"
      "catppuccin-icons"
    ];
    extraPackages = with pkgs; [
      nixd
      rust-analyzer
    ];

    userSettings = {
      agent.enabled = true;
      agent.default_model = {
        provider = "copilot_chat";
        model = "gpt-4.1";
      };

      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };

      journal.hour_format = "hour24";
      auto_update = false;

      lsp.rust_analyzer.binary.path_lookup = true;
      lsp.nix.binary.path_lookup = true;
      load_direnv = "shell_hook";
      base_keymap = "VSCode";

      buffer_font_family = terminalFont;
      buffer_font_size = 16.0;
      theme = "VSCode Dark Modern";
      ui_font_family = terminalFont;
      ui_font_size = 16.0;
      icon_theme = "Catppuccin Latte";
    };

    themes = {
      vscode-dark-modern = ./zed/themes/vscode-dark-modern.json;
    };
  };

  home.shellAliases = mkIf isDesktop {
    # Zed editor
    zed = "zeditor";
  };
}
