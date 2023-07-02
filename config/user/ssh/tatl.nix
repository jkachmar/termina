{config, ...}: let
  sshDir = "${config.home.homeDirectory}/.ssh";
in {
  programs.ssh.matchBlocks."192.168.1.151" = {
    hostname = "192.168.1.151";
    user = config.home.username;
    forwardAgent = true;
    identityFile = [
      "${sshDir}/id_gpg.pub"
      "${sshDir}/id_tatl"
    ];
  };
}
