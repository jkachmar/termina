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
      defaultNetwork.settings = {
        subnets = [
          {
            gateway = "172.25.0.1";
            subnet = "172.25.0.0/23";
          }
        ];
      };
    };

    oci-containers.backend = "podman";
  };

  environment.persistence."/state/root".directories = ["/var/lib/cni"];
}
