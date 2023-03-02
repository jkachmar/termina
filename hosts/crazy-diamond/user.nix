{config, pkgs, ...}: {
  imports = [
    ../../modules/home/primary-user.nix
    ../../config/user/devtools.nix
    ../../config/user/fonts.nix
    ../../config/user/neovim
    ../../config/user/nix.nix
    ../../config/user/nixpkgs.nix
    ../../config/user/ssh.nix
    ../../config/user/vscode
  ];

  home.packages = with pkgs; [ colima ];

  primary-user = {
    git.user = {
      inherit (config.primary-user) name;
      email = "git@jkachmar.com";
    };
  };
}
