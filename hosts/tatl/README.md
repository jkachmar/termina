## Structure

- [`disks.nix`] - disk partition management
- [`hardware.nix`] - additions/overrides to the auto-generated hardware survey
- [`survey.nix`] - NixOS hardware survey, auto-generated at installation
  - `nixos-generate-config --no-filesystems --show-hardware-config > survey.nix`
- [`system.nix`] - system-level (NixOS) configuration
- [`user.nix`] - user-level ([`home-manager`]) configuration

[`disks.nix`]: ./disks.nix
[`hardware.nix`]: ./hardware.nix
[`survey.nix`]: ./survey.nix
[`system.nix`]: ./system.nix
[`user.nix`]: ./user.nix

[`home-manager`]: https://www.github.com/nix-community/home-manager

## Setup

Perform the following steps from this directory.

### Prepare External LUKS Key Media

Format an external flash drive with 10 MiB of randomness; the LUKS key file
will be derived from this.

```shell
sudo disko ../../cassini.nix \
  --mode create \
  --argstr device <path to external key device>
```

### Prepare the System Device

Create primary system partitions, the encrypted LUKS container, the
primary ZFS pool, and all ZFS datasets as described by the `disko` config.

```shell
sudo disko ./disks.nix \
  --mode zap_create_mount \
  --argstr device <path to primary system device>
```

Set a fallback LUKS passphrase in case the external key file is unavailable.

```shell
sudo cryptsetup luksAddKey /dev/disk/by-partlabel/<path to LUKS partition> \
  --key-file <path to key file> \
  --keyfile-size <key file size> \
  --keyfile-offset <key file offset>
```

### Prepare Required Installation Files

```shell
sudo mkdir /mnt/secrets/<system hostname>
sudo cp -L /etc/machine-id /mnt/secrets/<system hostname>/machine-id
```

### Install NixOS

From the root of this repository:

```shell
sudo nixos-install --no-root-password --flake .#<system hostname>
```
