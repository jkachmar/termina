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

  # programs.ssh = {
  #   "10.0.1.150" = {
  #     hostname = "10.0.1.150";
  #     user = "jkachmar";
  #     identityFile = [
  #       "${secretAgentPubKeysPath}/ff67f327ddfda7771e3741f7bcdd95ce.pub"
  #     ];
  #   };
  #   "github".identityFile = lib.mkForce [
  #     "${secretAgentPubKeysPath}/8340b1d3d8b43aa144e30866ab4cfe05.pub"
  #   ];
  # };
}
