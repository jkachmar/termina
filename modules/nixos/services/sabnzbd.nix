{
  config,
  lib,
  ...
}: let
  inherit (config.networking) fqdn;
  cfg = config.services.sabnzbd;
  nginxCfg = config.services.nginx;
  dataDir = "/var/lib/sabnzbd";
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.persistence."/state/root".directories = [dataDir];
      # TODO: derive this from 'dataDir'.
      systemd.services.sabnzbd.after = ["var-lib-sabnzbd.mount"];
      # NOTE: primary group must be 'downloads' so the files are saved with
      # the appropriate group permissions.
      services.sabnzbd.group = "downloads";
    })

    (lib.mkIf (cfg.enable && nginxCfg.enable) {
      services.nginx.virtualHosts."sabnzbd.${fqdn}" = {
        forceSSL = config.security.acme.enable;
        useACMEHost = fqdn;
        # TODO: The NixOS module doesn't expose this for configuration; submit
        # a PR.
        locations."/".proxyPass = "http://localhost:8080";
      };
    })
  ];
}
