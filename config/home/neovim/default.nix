{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  myPlugins = pkgs.callPackage ./plugins.nix {};
in {
  # Lua needs a formatter.
  #
  # NOTE: Not this formatter, though; takes forever to compile.
  #
  # home.packages = with pkgs; [ luaformatter ];
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = true;

    # Always pull the latest plugins.
    plugins = with pkgs.vimPlugins;
    with myPlugins; [
      # Language support.
      vim-nix
      # UI.
      everforest
      gruvbox-material
      lightline-vim
      nvim-base16
      oceanic-next
      # Misc. tooling.
      commentary
      direnv-vim
      # Version control.
      # fugitive
      gitgutter
    ];

    # Minimal init.lua to load Lua config.
    #
    # Rather than configure this in Nix, it's more pleasant to manage this in
    # a separate file that we ensure it's symlinked appropriately.
    extraConfig = "lua require('init')";
  };

  # XXX: It's important that all systems store dotfiles at the same location.
  xdg.configFile."nvim/lua".source =
    mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.config/dotfiles/config/neovim/lua";
}
