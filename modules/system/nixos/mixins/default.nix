{
  imports = [
    ./boot.nix
    ./services/monitoring/smartd.nix
    ./services/security/fail2ban.nix
    ./services/security/openssh.nix
    ./ssh-agent.nix
    ./zfs.nix
    ./zramSwap.nix
  ];
}
