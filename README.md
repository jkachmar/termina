# antikythera

> an Ancient Greek hand-powered orrery; it is the oldest known example of an
> analogue computer.
> 
> **orrery** noun (_plural_ **orreries**)
> 
> a mechanical model of the solar system, or of just the sun, earth, and moon,
> used to represent their relative positions and motions.

## tl;dr

A mix of system- & user-level configurations for the machines that I
administer; shared here for convenience and in case anyone else finds them
useful.

### structure

- [`modules/`](./modules)
  - [`flake/`](./modules/flake) - modules that configure or extend flakes à la [`flake-parts`]
  - [`system/`](./modules/system) - "system-level" configuration/extension
    - [`shared/`](./modules/system/shared) - OS-agnostic modules
      - [`mixins/`](./modules/system/shared/mixins)
      - [`profiles/`](./modules/system/shared/profiles)
    - [`macos/`](./modules/system/macos) - macOS modules, courtesy of [`nix-darwin`]
      - [`mixins/`](./modules/system/macos/mixins)
      - [`profiles/`](./modules/system/macos/profiles)
    - [`nixos/`](./modules/system/nixos) - NixOS modules
      - [`mixins/`](./modules/system/nixos/mixins)
      - [`profiles/`](./modules/system/nixos/profiles)
  - [`home/`](./modules/home) - user-level configuration, courtesy of [`home-manager`]
      - [`mixins/`](./modules/system/nixos/mixins)
      - [`profiles/`](./modules/home/profiles)

[`disko`]: https://www.github.com/nix-community/disko
[`home-manager`]: https://www.github.com/nix-community/home-manager
[`flake-parts`]: https://www.github.com/hercules-ci/flake-parts

Note that `mixins` & `profiles` are design patterns that are shared between
`system` & `home` module groups:
- `mixins` extend built-in options provided by the configuration framework
  - e.g. an `ssh-agent` mixin might create an option to select `rssh` as the PAM framework for SSH AuthZ
- `profiles` collect/expose related configuration options under a common namespace
  - e.g. `profiles.base` contains common settings for all systems

## notes

### disko

`chronos`'s root partition can be formatted using its `diskoConfigurations`
entry; when run from this flake's directory, the following will wipe the NVMe
drive & install NixOS on the host:

```bash
$ nix develop
$ disko --flake .#hrodreptus --mode zap_create_mount
$ nixos-install --flake .#chronos --no-root-password
```

`--no-root-password` is necessary if (as the flag implies) `users.users.root`
doesn't have a password set. At the time of writing, root access is handled by
`ssh-agent` & `rssh` PAM, but this is kinda dicey from a recovery PoV.
