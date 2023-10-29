{
  config,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.services.linkding;
in {
  options.services.linkding = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = lib.mkDoc ''
        Enable the linkding self-hosted bookmark manager with some reasonable
        defaults my own deployment with Podman & root on tmpfs.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.persistence."/state/root".directories = ["/var/lib/linkding"];
    virtualisation.oci-containers.containers.linkding = {
      image = "docker.io/sissbruecker/linkding:latest";
      volumes = ["/var/lib/linkding:/etc/linkding/data"];
      ports = ["9090:9090"];
      extraOptions = ["--label=io.containers.autoupdate=registry"];
      environment = {
        LD_SUPERUSER_NAME = "jkachmar";
        LD_SUPERUSER_PASSWORD = "hunter2";
      };
    };
    systemd.services.podman-linkding.after = ["var-lib-linkding.mount"];
  };
}
