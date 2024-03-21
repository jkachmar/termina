{
  device,
  keyLabel ? "huygens",
  keyFile ? "/dev/disk/by-partlabel/${keyLabel}",
  keyFileSize ? 8096, # 8KiB
  keyFileOffset ? 4194304, # 4MiB
  ...
}: let
  devicename = builtins.baseNameOf device;
in {
  # Construct the partition table for the system's primary disk.
  disko.devices.disk.${devicename} = {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      # XXX: The explicit labels added below are workarounds to changes that
      # 'disko' has made to the partition label mapping.
      #
      # When this system is rebuilt, they can be removed (since the partition
      # map will be reconstructed). It would be nice to have a more reasonable
      # solution to this problem but w/e.
      partitions = {
        # Create a large boot partition.
        #
        # NixOS creates a separate boot entry for each generation, which
        # can fill up the partition faster than other operating systems.
        #
        # Storage is cheap, so this can be more generous than necessary.
        esp = {
          name = "ESP";
          label = "ESP";
          type = "EF00";
          start = "1MiB";
          end = "2GiB";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = ["defaults"];
          };
        };
        # Partition the remainder of the disk as a LUKS container.
        #
        # This system should be able to boot without manual intervention, so
        # the LUKS container will be set up to use a random segment data from
        # an external device constructed in a separate step.
        #
        # XXX: It's _extremely_ important to set up a separate LUKS passphrase
        # to unlock this container, so that the system is not irrecoverable if
        # something happens to the key file.
        phainon = {
          name = "phainon";
          label = "phainon";
          start = "2GiB";
          end = "100%";
          content = {
            type = "luks";
            name = "kronos";
            settings = {
              inherit keyFile keyFileSize keyFileOffset;
              allowDiscards = true;
              # XXX: implied by `systemd` stage 1 boot.
              # fallbackToPassword = true;
            };
            content = {
              type = "zfs";
              pool = "titan";
            };
          };
        };
      };
    };
  };

  # Mount `/` on `tmpfs`.
  #
  # NOTE: `tmpfs` doesn't reserve memory, so this can be liberal; as always,
  # there can be problems associated w/ over-provisioning memory so be careful
  # to balance these settings w/ ZRAM-swap (configured elsewhere).
  disko.devices.nodev."/" = {
    fsType = "tmpfs";
    mountOptions = ["defaults" "size=16G" "mode=755"];
  };

  # Mount `/tmp` on `tmpfs`.
  #
  # NOTE: `tmpfs` doesn't reserve memory, so this can be liberal; as always,
  # there can be problems associated w/ over-provisioning memory so be careful
  # to balance these settings w/ ZRAM-swap (configured elsewhere).
  disko.devices.nodev."/tmp" = {
    fsType = "tmpfs";
    mountOptions = ["defaults" "size=16G" "mode=1777"];
  };

  # Construct the primary ZFS pool for this system.
  disko.devices.zpool.titan = {
    type = "zpool";

    options = {
      ashift = "12";
      autotrim = "on";
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
        type = "zfs_fs";
        options = {
          canmount = "off";
          mountpoint = "none";
          refreservation = "2G";
          primarycache = "none";
          secondarycache = "none";
        };
      };

      # `/nix/store` dataset; no snapshots required.
      nix = {
        type = "zfs_fs";
        mountpoint = "/nix";
        options = {
          mountpoint = "legacy";
          relatime = "off";
          secondarycache = "none";
          "com.sun:auto-snapshot" = "false";
        };
      };

      # Persistent state.
      state = {
        type = "zfs_fs";
        options = {
          canmount = "off";
          mountpoint = "none";
          secondarycache = "none";
        };
      };

      # Root filesystem persistence; things that will be mounted under `/`
      "state/root" = {
        type = "zfs_fs";
        mountpoint = "/state/root";
        options = {
          mountpoint = "legacy";
          secondarycache = "none";
        };
      };

      # User filesystem persistence.
      "state/home" = {
        type = "zfs_fs";
        mountpoint = "/home";
        options = {
          mountpoint = "legacy";
          secondarycache = "none";
        };
      };

      # Arbitrary runtime secrets.
      #
      # NOTE: It would be nice to replace this with something like Vault.
      "state/secrets" = {
        type = "zfs_fs";
        mountpoint = "/secrets";
        options = {
          mountpoint = "legacy";
          secondarycache = "none";
        };
      };

      # Persistence without snapshotting; useful for media, downloads, etc.
      "state/no_snapshot" = {
        type = "zfs_fs";
        mountpoint = "/state/no_snapshot";
        options = {
          mountpoint = "legacy";
          secondarycache = "none";
          "com.sun:auto-snapshot" = "false";
        };
      };

      # `journald` log persistence.
      "state/logs" = {
        type = "zfs_fs";
        mountpoint = "/var/log";
        options = {
          mountpoint = "legacy";
          secondarycache = "none";
          "com.sun:auto-snapshot" = "false";
        };
      };

      # Podman image storage; used with the ZFS storage driver.
      "state/podman" = {
        type = "zfs_fs";
        mountpoint = "/state/podman";
        options = {
          mountpoint = "legacy";
          secondarycache = "none";
          "com.sun:auto-snapshot" = "false";
        };
      };
    };
  };
}
