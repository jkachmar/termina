{ lib, ... }:
{
  imports = [
    ../../modules/user/doom.nix
    ../../modules/user/git.nix
    ../../modules/user/jujutsu.nix
    ../../modules/user/zellij.nix
    ../../modules/user/neovim
    ../../modules/user/vscode
    ../../config/user/devtools.nix
  ];

  programs.git.enable = lib.mkDefault true;
  programs.jujutsu.enable = lib.mkDefault true;
  programs.neovim.enable = lib.mkDefault true;
  programs.zellij.enable = lib.mkDefault true;
}
