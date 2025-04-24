# TODO: Pull some of the networking stuff out into a profile.
{
  imports = [
    ../../modules/system/nixos
    ./disks/hrodreptus.nix
    ./networking.nix
  ];

  # TODO: move to 'disks/titan.nix' alongside the pool configuration.
  #
  # Aliases mapping between chassis bay number & device link identifier.
  #
  # Can be reloaded by updating this file & running `udevadm trigger` whenever
  # zpool membership is changed (e.g. when resilvering a failing array).
  environment.etc."zfs/vdev_id.conf".text = ''
    alias bay-1 wwn-0x5000cca2ebc2a8b7
    alias bay-2 wwn-0x5000cca2ecc334f9
    alias bay-3 wwn-0x5000cca2ecc07c5e
    alias bay-4 wwn-0x5000cca2ebc0b54a
    alias bay-5 wwn-0x5000cca2ecc0cabd
  '';

  profiles = {
    docs.enable = true;
    server.enable = true;
  };
}
