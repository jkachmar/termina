{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh.matchBlocks."stackage-builder.haskell.org" = {
    hostname = "stackage-builder.haskell.org";
    user = "curators";
    identityFile = ["${sshDir}/id_rsa_stackage"];
  };
}
