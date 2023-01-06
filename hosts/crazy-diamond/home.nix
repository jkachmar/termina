{config, ...}: let
  name = "jkachmar";
  secretAgentDataPath = "/Users/${name}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data";
  secretAgentPubKeysPath = "${secretAgentDataPath}/PublicKeys";
in {
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

  primary-user = {
    name = "jkachmar";
    git.user = {
      inherit (config.primary-user) name;
      email = "git@jkachmar.com";
    };
  };
}
