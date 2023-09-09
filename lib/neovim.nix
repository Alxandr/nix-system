{ neovim-flake }:
{ pkgs, system, lib, ... }:

let
  nvim = neovim-flake.packages.${system}.default.extendConfiguration {
    modules = [{
      config = {
        build.vimAlias = lib.mkDefault true;
        vim.languages = {
          enableLSP = lib.mkDefault false;
          enableFormat = lib.mkDefault true;
          enableTreesitter = lib.mkDefault true;
          enableExtraDiagnostics = lib.mkDefault false;
          enableDebugger = lib.mkDefault false;

          nix.enable = lib.mkDefault true;
          markdown.enable = lib.mkDefault true;
          bash.enable = lib.mkDefault true;
        };

        vim.visuals = {
          enable = lib.mkDefault true;
          nvimWebDevicons.enable = lib.mkDefault true;
          indentBlankline = {
            enable = lib.mkDefault true;
            fillChar = lib.mkDefault null;
            eolChar = lib.mkDefault null;
            showCurrContext = lib.mkDefault true;
          };
          cursorWordline = {
            enable = lib.mkDefault true;
            lineTimeout = lib.mkDefault 0;
          };
        };

        vim.statusline.lualine.enable = lib.mkDefault true;
        vim.theme.enable = true;
        vim.autopairs.enable = lib.mkDefault true;
        vim.autocomplete = {
          enable = lib.mkDefault true;
          type = lib.mkDefault "nvim-cmp";
        };
        vim.debugger.ui.enable = lib.mkDefault false;
        vim.filetree.nvimTreeLua.enable = lib.mkDefault true;
        vim.tabline.nvimBufferline.enable = lib.mkDefault true;
        vim.treesitter.context.enable = lib.mkDefault true;
        vim.keys = {
          enable = lib.mkDefault true;
          whichKey.enable = lib.mkDefault true;
        };
        vim.telescope = {
          enable = lib.mkDefault true;
          fileBrowser.enable = lib.mkDefault true;
        };
        vim.git = {
          enable = lib.mkDefault true;
          gitsigns.enable = lib.mkDefault true;
          gitsigns.codeActions = lib.mkDefault true;
        };
      };
    }];

    inherit pkgs;
  };

in
{
  environment.systemPackages = [ nvim ];
}
