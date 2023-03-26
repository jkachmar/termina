## Declarative Partition Management

### [`cassini.nix`]

Generic module to prepare a flash drive with random data from which a LUKS key
file can be derived.

Running the following command from this directory will **erase and format**
a drive with the partition table specified in [`cassini.nix`]:

```shell
sudo disko ./cassini.nix --mode zap_create_mount --argstr device <path to device>
```
...where `<path to device>` is some block device, such as `/dev/sdb`.

[`cassini.nix`]: ./cassini.nix

### [`oasis.nix`]

Symlink to the disk configuration module for [`oasis`].

[`oasis.nix`]: ../hosts/oasis/disks.nix
[`oasis`]: ../hosts/oasis
