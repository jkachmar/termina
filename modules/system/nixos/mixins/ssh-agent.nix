{ config, lib, ... }:
let
  cfg = config.security.ssh-agent;
in
{
  options.security.ssh-agent.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = lib.mkDoc ''
      Enable ssh-agent auth support for passwordless sudo  via 'rssh'.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.startAgent = true;
    security.sudo.enable = true;
    security.pam = {
      sshAgentAuth.enable = true;
      services.sudo.rssh = true;
    };
  };
}
