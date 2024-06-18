{ config, lib, ... }:
let
  cfg = config.services.fail2ban;
in
{
  config = lib.mkIf cfg.enable {
    environment.persistence."/state/root".directories = [ "/var/lib/fail2ban" ];
    systemd.services.fail2ban.after = [ "var-lib-fail2ban.mount" ];
  };
}
