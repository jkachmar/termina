{config, pkgs, ...}: {
  imports = [
    ../../modules/home/primary-user.nix
    ../../config/home/devtools.nix
    ../../config/home/fonts.nix
    ../../config/home/neovim
    ../../config/home/nix.nix
    ../../config/home/nixpkgs.nix
    ../../config/home/ssh.nix
    ../../config/home/vscode
  ];

  home.packages = with pkgs; [ colima ];

  primary-user = {
    git.user = {
      inherit (config.primary-user) name;
      email = "git@jkachmar.com";
    };
  };
}
