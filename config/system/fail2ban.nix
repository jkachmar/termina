{
  services.fail2ban.enable = true;
  environment.persistence."/state/root".directories = ["/var/lib/fail2ban"];
  systemd.services.fail2ban.after = [ "var-lib-fail2ban.mount" ];
}
