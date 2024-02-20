{lib, ...}: {
  imports = [
    ../../modules/user/git.nix
    ../../modules/user/jujutsu.nix
    ../../config/user/devtools.nix
    ../../config/user/neovim
  ];
  programs.git.enable = lib.mkDefault true;
  programs.jujutsu.enable = lib.mkDefault true;
}
