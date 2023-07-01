{config, ...}: {
  imports = [
    ../../profiles/user/base.nix
    ../../profiles/user/development.nix
  ];

  primary-user.git.user = {
    inherit (config.primary-user) name;
    email = "git@jkachmar.com";
  };
}
