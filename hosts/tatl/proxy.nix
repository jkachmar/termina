{
  config,
  lib,
  ...
}: let
  inherit (config.networking) domain;
  nginxCfg = config.services.nginx;
  ip = "192.168.1.155";
in {
  config = lib.mkIf nginxCfg.enable {
    security.acme.certs."moody-blues.${domain}".extraDomainNames = ["*.moody-blues.${domain}"];

    services.nginx.virtualHosts = {
      # NOTE: Ensure this server is trusted by adding its IP to the NAS via
      # 'Control Panel' -> 'Security' -> 'Trusted Proxies' in the DSM webapp.
      "moody-blues.${domain}" = {
        forceSSL = config.security.acme.enable;
        useACMEHost = "moody-blues.${domain}";
        locations."/" = {
          proxyPass = "https://${ip}:5001";
          extraConfig = ''
            # Causes issues w/ uploading very large files via Synology web UI.
            client_max_body_size 0;
            proxy_request_buffering off;
          '';
        };
      };

      "webdav.moody-blues.${domain}" = {
        forceSSL = config.security.acme.enable;
        useACMEHost = "moody-blues.${domain}";
        locations."/".proxyPass = "https://${ip}:5006";
      };
    };
  };
}
