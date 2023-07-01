{
  programs.ssh.startAgent = true;
  security.sudo.enable = true;
  security.pam = {
    enableSSHAgentAuth = true;
    services.sudo.sshAgentAuth = true;
  };
}
