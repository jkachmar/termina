{ config, ... }:
let
  sshDir = "${config.home.homeDirectory}/.ssh";
in
{
  programs.ssh.matchBlocks = {
    "192.168.1.150".hostname = "192.168.1.150";
    "enigma.thempire.dev".hostname = "enigma.thempire.dev";
    "192.168.1.150 enigma.thempire.dev" = {
      hostname = "192.168.1.150";
      user = config.home.username;
      forwardAgent = true;
      identityFile = [ "${sshDir}/id_gpg.pub" ];
    };
  };
}
