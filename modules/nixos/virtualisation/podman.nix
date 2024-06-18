{ config, lib, ... }:
let
  inherit (lib) types;
  cfg = config.virtualisation.podman;
in
{
  options.virtualisation.podman = {
    autoUpdate = lib.mkOption {
      type = types.bool;
      default = true;
      description = lib.mkDoc ''
        This option enables the 'podman-auto-update.timer' unit which triggers
        'podman-auto-update.service' daily at midnight (by default).

        This will update any running containers with the label 'io.containers.autoUpdate'
        and restart them.

        See https://docs.podman.io/en/latest/markdown/podman-auto-update.1.html
        for details.
      '';
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (lib.mkIf cfg.enable {
        virtualisation = {
          containers.storage.settings.storage = {
            driver = "zfs";
            graphroot = "/state/podman/containers";
            runroot = "/run/containers/storage";
          };
          podman.defaultNetwork.settings.subnets = [
            {
              gateway = "172.25.0.1";
              subnet = "172.25.0.0/23";
            }
          ];
        };
      })
      (lib.mkIf cfg.autoUpdate { systemd.timers.podman-auto-update.wantedBy = [ "timers.target" ]; })
    ]
  );
}
