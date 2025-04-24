{ ... }:
{
  disko.devices = {
    disk.hrodreptus = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SHPP41-500GM_SSB4N671910504N4W";
      content = {
        type = "gpt";
        partitions = {
          # Create a large boot partition.
          #
          # NixOS creates a separate boot entry for each generation, which
          # can fill up the partition faster than other operating systems.
          #
          # Storage is cheap, so this can be more generous than necessary.
          esp = {
            name = "ESP";
            type = "EF00";
            size = "2G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          swap = {
            size = "12G"; # 12G = 0.2*64G RAM
            content = {
              type = "swap";
              priority = 5; # NOTE: _must_ be lower priority than 'zramSwap'.
              randomEncryption = true;
              discardPolicy = "both";
            };
          };
          hrodreptus = {
            name = "hrodreptus";
            size = "100%";
            content = {
              type = "zfs";
              pool = "hrodreptus";
            };
          };
        };
      };
    };

    zpool.hrodreptus = {
      type = "zpool";

      options = {
        autoexpand = "on";
        autotrim = "on";
      };

      # NOTE: Shockingly, 'smartctl -a' reports that 512k & 4M LBA sizes have
      # the same relative performance; 'ashift=9' will be set implicitly and
      # there shouldn't be negative perf impact.
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
        "com.sun:auto-snapshot" = "true"; # make snapshotting opt-out
      };

      datasets = {
        # Static reservation so the pool will never be 100% full; ZFS slows
        # down if it's >90% full (Nix needs some disk space available to clean
        # up the store, so it's always useful to have _some_ headroom).
        reservation = {
          type = "zfs_fs";
          options = {
            canmount = "off";
            mountpoint = "none";
            refreservation = "45G";
          };
        };

        # `/nix/store` dataset; no snapshots or 'atime' required.
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
          options = {
            relatime = "off";
            "com.sun:auto-snapshot" = "false";
          };
        };

        # Root filesystem persistence; things that will be mounted under `/`
        "root" = {
          type = "zfs_fs";
          mountpoint = "/";
        };

        # User filesystem persistence.
        "home" = {
          type = "zfs_fs";
          mountpoint = "/home";
        };
        "home/jkachmar" = {
          type = "zfs_fs";
          mountpoint = "/home/jkachmar";
        };

        # `journald` persistence.
        "logs" = {
          type = "zfs_fs";
          mountpoint = "/var/log";
          options."com.sun:auto-snapshot" = "false";
        };

        # `tmp` storage that needs to persist between reboots.
        "tmp" = {
          type = "zfs_fs";
          mountpoint = "/var/tmp";
          options = {
            "com.sun:auto-snapshot" = "false";
            # Arch wiki recommendations.
            #
            # cf. https://wiki.archlinux.org/title/ZFS#/tmp
            devices = "off";
            setuid = "off";
            sync = "disabled";
          };
        };
      };
    };
  };
}
