# TODO: Pull some of the networking stuff out into a profile.
{
  imports = [
    ../../modules/system/nixos
    ./disks/hrodreptus.nix
    ./disks/titan.nix
    ./networking.nix
  ];

  # TODO: move to 'disks/titan.nix' alongside the pool configuration.
  #
  # Aliases mapping between chassis bay number & device link identifier.
  #
  # Can be reloaded by updating this file & running `udevadm trigger` whenever
  # zpool membership is changed (e.g. when resilvering a failing array).
  environment.etc."zfs/vdev_id.conf".text = ''
    alias bay-1 pci-0000:00:17.0-ata-1
    alias bay-2 pci-0000:00:17.0-ata-2
    alias bay-3 pci-0000:00:17.0-ata-3
    alias bay-4 pci-0000:00:17.0-ata-4
    alias bay-5 pci-0000:00:17.0-ata-6
  '';

  profiles = {
    docs.enable = true;
    server.enable = true;
  };
}
