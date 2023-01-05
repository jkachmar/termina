{config, ...}: let
  name = "jkachmar";
  secretAgentDataPath = "/Users/${name}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data";
  secretAgentPubKeysPath = "${secretAgentDataPath}/PublicKeys";
in {
  imports = [
    ../../modules/home/primary-user.nix
    ../../config/home
  ];

  primary-user.name = "jkachmar";
  primary-user.git.user = {
    name = config.primary-user.name;
    git.user.email = "git@jkachmar.com";
  };

  programs.ssh = {
    "10.0.1.150" = {
      hostname = "10.0.1.150";
      user = "jkachmar";
      identityFile = [
        "${secretAgentPubKeysPath}/ff67f327ddfda7771e3741f7bcdd95ce.pub"
      ];
    };
    "github".identityFile = lib.mkForce [
      "${secretAgentPubKeysPath}/8340b1d3d8b43aa144e30866ab4cfe05.pub"
    ];
  };
}
