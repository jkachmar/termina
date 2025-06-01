{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.server;
in
{
  options.profiles.server = {
    enable = lib.mkEnableOption "server profile";
  };

  config = lib.mkIf cfg.enable {
    profiles.monitoring.enable = lib.mkDefault true;

    security.ssh-agent.enable = true;
    services = {
      fail2ban.enable = lib.mkDefault true;
      openssh.enable = true;
      smartd.enable = true;
    };
    networking = {
      firewall.enable = true;
      nftables.enable = true;
    };
  };
}
