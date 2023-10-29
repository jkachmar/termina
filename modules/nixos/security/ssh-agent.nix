{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.security.ssh-agent;
in {
  options.security.ssh-agent.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = lib.mkDoc ''
      Enable ssh-agent auth support for passwordless sudo.
    '';
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.startAgent = true;
    security.sudo.enable = true;
    security.pam = {
      enableSSHAgentAuth = true;
      services.sudo.sshAgentAuth = true;
    };
  };
}
