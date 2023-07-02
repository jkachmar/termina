{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh.matchBlocks."cofree.coffee" = {
    hostname = "cofree.coffee";
    user = config.home.username;
    forwardAgent = true;
    identityFile = ["${sshDir}/id_cofree"];
  };
}
