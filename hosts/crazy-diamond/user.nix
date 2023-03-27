{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../profiles/user/base.nix
    ../../profiles/user/development.nix
    # SSH identity management
    # TODO: There's absolutely a better solution than this...
    ../../config/user/ssh
    ../../config/user/ssh/enigma.nix
    ../../config/user/ssh/github.nix
    ../../config/user/ssh/gitlab.nix
    ../../config/user/ssh/stackage.nix
  ];

  home.packages = with pkgs; [colima];

  primary-user.git.user = {
    inherit (config.primary-user) name;
    email = "git@jkachmar.com";
  };
}
