{ lib, ... }:
let
  # Enumerate disks by the aliases defined in `/etc/zfs/vdev_id.conf`:
  # "/dev/disk/by-vdev/{bay-1,bay-2,bay-3,bay-4,bay-5}".
  aliases = builtins.map (n: "bay-${builtins.toString n}") (lib.lists.range 1 5);
in {
  boot.zfs = {
    # NOTE: ZFS auto-mounts datasets with the `mountpoint` label on import;
    # adding it to `extraPools` triggers the import, which mounts the datasets. 
    #
    # cf. https://github.com/nix-community/disko/issues/581#issuecomment-2260602290
    extraPools = ["titan"];

    # NOTE: These disks are being specified by `vdev_id` alias so the pool
    # should be discovered/imported according to these aliases.
    pools.titan.devNodes = "/dev/disk/by-vdev";
  };

  disko.devices = {
    disk = lib.genAttrs aliases (alias: {
      type = "disk";
      device = "/dev/disk/by-vdev/${alias}";
      content = {
        type = "gpt";
        partitions.zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "titan";
          };
        };
      };
    });

    zpool.titan = {
      type = "zpool";

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

      mode.topology = {
        type = "topology";
        vdev = [{
          mode = "raidz2";
          members = aliases;
        }];
      };

      datasets = {
        # Static reservation so the pool will never be 100% full; ZFS slows down
        # if it's >90% full.
        #
        # In reality ZFS is probably fine up till ~94% capacity, but if the first
        # threshold gets hit then the reservation can be resized until more space
        # is allocated.
        reservation = {
          type = "zfs_fs";
          options = {
            canmount = "off";
            mountpoint = "none";
            refreservation = "4.8T";
          };
        };
        media = {
          type = "zfs_fs";
          options.mountpoint = "/mnt/media";
        };
        "media/movies" = {
          type = "zfs_fs";
          options.mountpoint = "/mnt/media/movies";
        };
        "media/tv" = {
          type = "zfs_fs";
          options.mountpoint = "/mnt/media/tv";
        };
      };
    };
  };
}
