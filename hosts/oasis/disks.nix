{
  device,
  keyLabel ? "huygens",
  keyFile ? "/dev/disk/by-partlabel/${keyLabel}",
  ...
}: let
  devicename = builtins.baseNameOf device;
in {
  # TODO: Documentation!
  disk.${devicename} = {
    type = "disk";
    inherit device;
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        # Create a large boot partition.
        #
        # NixOS creates a separate boot entry for each generation, which
        # can fill up the partition faster than other operating systems.
        #
        # Storage is cheap, so this can be more generous than necessary.
        {
          type = "partition";
          name = "ESP";
          start = "1MiB";
          end = "2GiB";
          bootable = true;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["defaults"];
          };
        }
        {
          type = "partition";
          name = "phainon";
          start = "2GiB";
          end = "100%";
          content = {
            type = "luks";
            name = "kronos";
            inherit keyFile;
            keyFileSize = 8096; # 8KiB
            keyFileOffset = 4194304; # 4MiB
            content = {
              type = "zfs";
              pool = "titan";
            };
          };
        }
      ];
    };
  };

  # Mount `/` on `tmpfs`.
  #
  # NOTE: `tmpfs` doesn't reserve memory, so this can be liberal; as always,
  # there can be problems associated w/ over-provisioning memory so be careful
  # to balance these settings w/ ZRAM-swap (configured elsewhere).
  nodev."/" = {
    fsType = "tmpfs";
    mountOptions = ["defaults" "size=16G" "mode=755"];
  };

  # Mount `/tmp` on `tmpfs`.
  #
  # NOTE: `tmpfs` doesn't reserve memory, so this can be liberal; as always,
  # there can be problems associated w/ over-provisioning memory so be careful
  # to balance these settings w/ ZRAM-swap (configured elsewhere).
  nodev."/tmp" = {
    fsType = "tmpfs";
    mountOptions = ["defaults" "size=16G" "mode=1777"];
  };

  # TODO: Documentation!
  zpool.titan = {
    type = "zpool";

    options = {
      ashift = "12";
      listsnapshots = "on";
    };

    rootFsOptions = {
      acltype = "posixacl";
      atime = "off";
      canmount = "off";
      compression = "zstd";
      dnodesize = "auto";
      mountpoint = "none";
      normalization = "formD";
      relatime = "on";
      xattr = "sa";
      "com.sun:auto-snapshot" = "true";
    };

    datasets = {
      # Static reservation so the pool will never be 100% full.
      #
      # If a pool fills up completely, delete this & reclaim space; don't
      # forget to re-create it afterwards!
      reservation = {
        zfs_type = "filesystem";
        options.mountpoint = "none";
        options.refreservation = "2G";
        options.primarycache = "none";
        options.secondarycache = "none";
      };

      # Nix store.
      nix = {
        zfs_type = "filesystem";
        mountpoint = "/nix";
        options.mountpoint = "legacy";
        options.relatime = "off";
        options.secondarycache = "none";
        options."com.sun:auto-snapshot" = "false";
      };

      # Persistent state.
      state = {
        zfs_type = "filesystem";
        options.mountpoint = "none";
        options.secondarycache = "none";
      };

      # Root filesystem persistence; things that will be mounted under `/`
      "state/root" = {
        zfs_type = "filesystem";
        mountpoint = "/state/root";
        options.mountpoint = "legacy";
        options.secondarycache = "none";
      };

      # User filesystem persistence.
      "state/home" = {
        zfs_type = "filesystem";
        mountpoint = "/home";
        options.mountpoint = "legacy";
        options.secondarycache = "none";
      };

      # Location for runtime "secrets".
      #
      # NOTE: It would be nice to replace this with something like Vault.
      "state/secrets" = {
        zfs_type = "filesystem";
        mountpoint = "/secrets";
        options.mountpoint = "legacy";
        options.secondarycache = "none";
      };

      # Persistence without snapshotting; useful for media, downloads, etc.
      "state/nobackup" = {
        zfs_type = "filesystem";
        mountpoint = "/state/nobackup";
        options.mountpoint = "legacy";
        options.secondarycache = "none";
        options."com.sun:auto-snapshot" = "false";
      };

      # `journald` log persistence.
      "state/logs" = {
        zfs_type = "filesystem";
        mountpoint = "/var/log";
        options.mountpoint = "legacy";
        options.secondarycache = "none";
        options."com.sun:auto-snapshot" = "false";
      };

      # Podman image storage; used with the ZFS storage driver.
      "state/podman" = {
        zfs_type = "filesystem";
        mountpoint = "/state/podman";
        options.mountpoint = "legacy";
        options.secondarycache = "none";
        options."com.sun:auto-snapshot" = "false";
      };
    };
  };
}
