{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh.matchBlocks."cofree.coffee" = {
    hostname = "cofree.coffee";
    user = "jkachmar";
    identityFile = ["${sshDir}/id_cofree"];
    forwardAgent = true;
  };
}
