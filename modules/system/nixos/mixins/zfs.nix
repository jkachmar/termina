{ config, lib, ... }:

lib.mkIf config.boot.zfs.enabled {
  # Use the same default hostID as the NixOS install ISO; this allows us
  # to import the ZFS pool without using a force import.
  #
  # Uniqueness is only required for high-availability ZFS or iSCSI.
  networking.hostId = lib.mkDefault "8425e349";

  # TODO: Set up zed + email alerts on scrub errors.
  services.zfs = {
    # Enable TRIM.
    trim.enable = lib.mkDefault true;
    # Enable automatic scrubbing and snapshotting.
    autoScrub.enable = lib.mkDefault true;
    autoSnapshot = {
      enable = lib.mkDefault true;
      frequent = lib.mkDefault 4;
      daily = lib.mkDefault 3;
      weekly = lib.mkDefault 2;
      monthly = lib.mkDefault 2;
    };
  };
}
