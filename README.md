# I Fucking Hate Dotfiles

![Link standing on the Great Plateau, from Breath of the Wild, looking out over Hyrule](./plateau.jpg)

## TL;DR

A mix of system- & user-level configurations for the machines that I
administer; shared here for convenience and in case anyone else finds them
useful.

### Structure

- [`flake/`] - "flake modules" to be used with [`flake-parts`]
  - [`devshells.nix`] - system-agnostic development shells
  - [`macos.nix`] - macOS configuration targets
  - [`nixos.nix`] - NixOS configuration targets
  - [`user.nix`] - user-level configuration targets
- [`config/`]
  - [`shared/`] - settings shared between system & user configs
  - [`system/`] - system-level configuration options (Nix itself, dev tools, services)
    - [`macos/`] - macOS system-level configs (homebrew, app store, dock, inputs)
  - [`user/`] - user-level configuration (i.e. dotfile management)
- [`disks/`] - declarative disk partition configuration, courtesy of [`disko`]
- [`profiles/`] - collections of configuration options from which high-level system "profiles" are comprised
  - e.g. `profiles/user/base.nix` is a user-level profile for all systems
- [`hosts/`] - system & user configs for the different hosts administered here
- [`modules/`] - custom modules used in system- or user-level configuration
- [`overlays/`] - just what it says: any overlays that should be applied to the package sets used herein
- [`scripts/`] - shell scripts & other utilities

[`flake/`]: ./flake
[`devshells.nix`]: ./flake/devshells.nix
[`macos.nix`]: ./flake/macos.nix
[`nixos.nix`]: ./flake/nixos.nix
[`user.nix`]: ./flake/user.nix
[`config/`]: ./config
[`shared/`]: ./config/shared
[`system/`]: ./config/system
[`macos/`]: ./config/system/macos
[`user/`]: ./config/user
[`disks/`]: ./disks
[`profiles/`]: ./profiles
[`hosts/`]: ./hosts
[`modules/`]: ./modules
[`overlays/`]: ./overlays
[`scripts/`]: ./scripts

[`disko`]: https://www.github.com/nix-community/disko
[`flake-parts`]: https://www.github.com/hercules-ci/flake-parts

## NOTES

<details><summary> TODO </summary>

- [ ] init with [colmena](https://github.com/zhaofengli/colmena)
- [ ] test out [remote builds](https://colmena.cli.rs/unstable/features/remote-builds.html)
    - a macOS host should be able to deploy a config to a NixOS/Linux target
- [ ] test out [binfmt emulation](https://colmena.cli.rs/unstable/examples/multi-arch.html#using-binfmt-emulation)
    - a x86_64-linux host should be able to build an aarch64-linux deployment **locally** (i.e. cross-arch) and then deploy it to a target
    - try this out with some [native images](https://nixos.wiki/wiki/NixOS_on_ARM#Build_your_own_image_natively) for a Raspberry Pi built on an `x86_64-linux` machine
- [ ] minimize plaintext keys stored on device with [secrets](https://colmena.cli.rs/unstable/features/keys.html)
    - plaintext keys should _only_ decrypt system partitions
    - all data partitions (and associated services) await some corresponding `systemd` unit, which indicates that the secret has been supplied
    - MVP is just reading from some plaintext files on the host
    - later iteration 
    - be very careful to always permit SSH access (leave allowed public keys in the config file) so as to avoid having to manually connect up to the machine and debug

</details>
