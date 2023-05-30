{config, ...}: {
  imports = [
    ../../profiles/user/base.nix
    ../../config/user/neovim
  ];

  primary-user.git.user = {
    inherit (config.primary-user) name;
    email = "git@jkachmar.com";
  };
}
