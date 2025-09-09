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

- [`hosts/`](./hosts): host configurations
  - [`chronos/`](./hosts/chronos): NixOS home server & NAS
  - [`moros/`](./hosts/moros): personal laptop (M2 MacBook Pro)
  - [`prometheus/`](./hosts/prometheus): work-issued laptop (M4 MacBook Pro)
- [`modules/`](./modules): config & options modules laid out according to [RFC 0140](https://github.com/NixOS/rfcs/pull/140)
  - each terminal directory contains one or more of the following files, which are automatically collected in flake outputs:
    - `module.nix`: modules that are compatible with both NixOS & [`nix-darwin`]
    - `darwin-module.nix`: [`nix-darwin`] system modules
    - `nixos-module.nix`: NixOS system modules
    - `home-module.nix`: [`home-manager`] modules
    - `flake-module.nix`: [`flake-parts`] modules
- [`overlays/`](./overlays): overlays that are exposed in this flake & applied to some of the package sets I use
- [`users/`](./users): user configurations, typically exposing [`flake-parts`] modules containing variations on the following:
  - `darwinModules.jkachmar`: [`nix-darwin`] configuration for my personal user profile
  - `nixosModules.jkachmar`: NixOS system configuration for my personal user profile
  - `homeModules.jkachmar`: [`home-manager`] configuration for my personal user profile

[`nix-darwin`]: https://www.github.com/nix-darwin/nix-darwin
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
