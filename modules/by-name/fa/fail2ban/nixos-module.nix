{ config, lib, ... }:
let
  cfg = config.services.fail2ban;
in
{
  services.fail2ban = {
    # Ban SSH port scanning after 5 attempts.
    maxretry = lib.mkDefault 5;
    bantime-increment = {
      enable = lib.mkDefault true;
      maxtime = lib.mkDefault "2h";
      overalljails = lib.mkDefault true;
    };
  };
}
