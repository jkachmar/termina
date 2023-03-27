{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh.matchBlocks."gitlab.com" = {
    hostname = "gitlab.com";
    user = "git";
    identityFile = ["${sshDir}/id_gitlab"];
  };
}
