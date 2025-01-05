# tartarus

<p align="center">
  <a href="tartarus.jpg">
    <img src="tartarus.jpg" height="auto" width="500px" alt="image of Tartarus from Hades 2">
  </a>
</p>

> How exactly the Titan escaped an inescapable prison, he alone can say. But the
> groaning wheels and machinery throughout the place have grown more prevalent
> since his return, suggesting long-dormant plans that came finally to fruition.

## tl;dr

A mix of system- & user-level configurations for the machines that I
administer; shared here for convenience and in case anyone else finds them
useful.

### structure

- [`machines/`](./machines) - machine-specific configurations
  - [`moros/`](./machines/moros) - personal laptop (M2 MacBook Pro)
  - [`prometheus/`](./machines/prometheus) - work-issued laptop (M4 MacBook Pro)
- [`modules/`](./modules)
  - [`flake/`](./modules/flake) - modules that configure or extend flakes à la [`flake-parts`]
  - [`system/`](./modules/system) - "system-level" configuration/extension
    - [`common/`](./modules/system/common) - OS-agnostic modules
    - [`macos/`](./modules/system/macos) - macOS modules, courtesy of [`nix-darwin`]
    - [`nixos/`](./modules/system/nixos) - NixOS modules
  - [`home/`](./modules/home) - user-level configuration, courtesy of [`home-manager`]

[`disko`]: https://www.github.com/nix-community/disko
[`home-manager`]: https://www.github.com/nix-community/home-manager
[`flake-parts`]: https://www.github.com/hercules-ci/flake-parts

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
