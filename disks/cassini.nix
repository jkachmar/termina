{device, ...}: let
  devicename = builtins.baseNameOf device;
in {
  #############################################################################
  # Wipe some disk (typically a flash drive) and fill (approx.) the first 10M
  # of space with randomness, from which a LUKS key will be derived.
  disk."${devicename}" = {
    type = "disk";
    inherit device;
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        # Create the partition that will store random data from which the LUKS
        # key will be derived.
        rec {
          type = "partition";
          name = "huygens";
          start = "1MiB";
          end = "10MiB";
          # Write randomness to this partition; the whole disk should have been
          # shredded before, anyway, but we're here so whatever.
          postCreateHook = ''
            dd if=/dev/urandom of=/dev/disk/by-partlabel/${name} bs=1MiB count=9
          '';
        }
        # Flash drives are big nowadays; might as well make the rest usable.
        {
          type = "partition";
          name = "cassini";
          start = "10MiB";
          end = "100%";
          fs-type = "fat32";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = null;
          };
        }
      ];
    };
  };
}
