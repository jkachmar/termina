{
  config,
  lib,
  ...
}: let
  inherit (config.networking) fqdn;
  cfg = config.services.sonarr;
  nginxCfg = config.services.nginx;
  dataDir = "/var/lib/sonarr";
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.persistence."/state/root".directories = [dataDir];
      # TODO: derive this from 'dataDir'.
      systemd.services.sonarr.after = ["var-lib-sonarr.mount"];
      services.sonarr = {
        inherit dataDir;
        openFirewall = true;
      };
      users.users.${cfg.user}.extraGroups = ["downloads"];
    })

    (lib.mkIf (cfg.enable && nginxCfg.enable) {
      services.nginx.virtualHosts."sonarr.${fqdn}" = {
        forceSSL = config.security.acme.enable;
        useACMEHost = fqdn;
        # TODO: The NixOS module doesn't expose this for configuration; submit
        # a PR.
        locations."/".proxyPass = "http://localhost:8989";
      };
    })
  ];
}
