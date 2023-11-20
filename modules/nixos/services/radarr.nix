{
  config,
  lib,
  ...
}: let
  inherit (config.networking) fqdn;
  cfg = config.services.radarr;
  nginxCfg = config.services.nginx;
  dataDir = "/var/lib/radarr";
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.persistence."/state/root".directories = [dataDir];
      # TODO: derive this from 'dataDir'.
      systemd.services.radarr.after = ["var-lib-radarr.mount"];
      services.radarr = {
        inherit dataDir;
        openFirewall = true;
      };
      users.users.${cfg.user}.extraGroups = ["downloads"];
    })

    (lib.mkIf (cfg.enable && nginxCfg.enable) {
      services.nginx.virtualHosts."radarr.${fqdn}" = {
        forceSSL = config.security.acme.enable;
        useACMEHost = fqdn;
        # TODO: The NixOS module doesn't expose this for configuration; submit
        # a PR.
        locations."/".proxyPass = "http://localhost:7878";
      };
    })
  ];
}
