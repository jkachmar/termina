{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh.matchBlocks."github.com" = {
    hostname = "github.com";
    user = "git";
    identityFile = ["${sshDir}/id_github"];
  };
}
