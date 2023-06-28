{
  config,
  inputs,
  lib,
  pkgs,
  pkgsets,
  ...
}: let
  inherit (pkgs.buildPlatform) isDarwin isLinux;
  inherit (import ../shared/caches.nix) substituters trusted-public-keys;
  dotfiles = "${config.primary-user.home-manager.xdg.configHome}/dotfiles";
  darwinCfg = "${dotfiles}/hosts/${config.networking.hostName}/system.nix";
in {
  nix = {
    package = pkgs.nixFlakes;

    settings = {
      experimental-features = ["nix-command" "flakes"];
      inherit substituters trusted-public-keys;
    };

    nixPath = lib.mkForce ([
        "nixpkgs=${pkgsets.nixpkgs}"
        "unstable=${pkgsets.unstable}"
      ]
      ++ lib.optionals isDarwin [
        "darwin=${inputs.darwin}"
        "darwin-config=${darwinCfg}"
      ]);

    # FIXME: Duplicated; see user-level Nix config.
    registry = {
      nixpkgs.flake = pkgsets.nixpkgs;
      unstable.flake = pkgsets.nixpkgs;
    };
  };

  nixpkgs = {
    config = import ../shared/nixpkgs.nix;
    # TODO: Stick construct overlays in `flake.nix` and stick them in the
    # module args (or something).
    overlays = [];
  };
}
