{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh.matchBlocks."build.stackage.org" = {
    hostname = "build.stackage.org";
    user = "curators";
    identityFile = ["${sshDir}/id_rsa_stackage"];
  };
}
