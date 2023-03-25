{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../profiles/user/base.nix
    ../../config/user/fonts.nix
    ../../config/user/neovim
    ../../config/user/ssh.nix
    ../../config/user/vscode
  ];

  home.packages = with pkgs; [colima];

  primary-user.git.user = {
    inherit (config.primary-user) name;
    email = "git@jkachmar.com";
  };
}
