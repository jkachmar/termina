{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.programs.neovim;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  myPlugins = pkgs.callPackage ./plugins.nix { };
in
lib.mkIf cfg.enable {
  programs.neovim = {
    package = pkgs.neovim-unwrapped;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    withNodeJs = true;
    withPython3 = true;

    # Always pull the latest plugins.
    plugins =
      (with unstable.vimPlugins; [
        # Language support.
        vim-nix
        # Misc. tooling.
        commentary
        direnv-vim
        # UI
        lightline-vim
        # Version control.
        fugitive
        gitgutter
      ])
      ++ (with myPlugins; [
        # UI.
        gruvbox-material
      ]);

    # Minimal `init.lua` to load Lua config.
    #
    # Rather than configure this in Nix, it's more pleasant to manage this in
    # a separate file that we ensure it's symlinked appropriately.
    extraConfig = "lua require('init')";
  };

  # XXX: It's important that all systems store dotfiles at the same location.
  xdg.configFile."nvim/lua".source = mkOutOfStoreSymlink "${config.xdg.configHome}/dotfiles/modules/user/neovim/lua";
}
