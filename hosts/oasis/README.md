### Structure

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
