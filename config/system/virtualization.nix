{pkgs, ...}: {
  # Use Podman to run OCI containers.
  virtualisation = {
    containers = {
      enable = true;
      storage.settings.storage = {
        driver = "zfs";
        graphroot = "/state/podman/containers";
        runroot = "/run/containers/storage";
      };
    };

    podman = {
      enable = true;
      autoUpdate = true;
    };

    oci-containers.backend = "podman";
  };

  environment.persistence."/state/root".directories = ["/var/lib/cni"];
}
