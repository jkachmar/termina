{ config, lib, ... }:
let
  cfg = config.services.nginx;
in
{
  config = lib.mkIf cfg.enable {
    services.nginx = {
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedProxySettings = true;
    };

    networking.firewall = {
      allowedTCPPorts = [
        80
        443
      ];
      allowedUDPPorts = [
        80
        443
      ];
    };

    # Nginx needs to be able to read the certificates
    users.users.nginx.extraGroups = [ "acme" ];
  };
}
