{
  config,
  inputs,
  lib,
  pkgs,
  pkgsets,
  ...
}:
let
  inherit (pkgs.buildPlatform) isDarwin isLinux;
  inherit (import ../shared/caches.nix) substituters trusted-public-keys;
  dotfiles = "${config.primary-user.home-manager.xdg.configHome}/dotfiles";
  darwinCfg = "${dotfiles}/hosts/${config.networking.hostName}/system.nix";
in
{
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      inherit substituters trusted-public-keys;
    };

    # Set '$NIX_PATH' entries to point to the local registry.
    nixPath = (builtins.map (pkgset: "${pkgset}=flake:${pkgset}") [
      "nixpkgs"
      "unstable"
    ]) ++ lib.optionals isDarwin [
      "darwin=${inputs.darwin}"
      "darwin-config=${darwinCfg}"
    ];

    channel.enable = false; # Use flakes for everything!
    # FIXME: Duplicated; see user-level Nix config.
    registry = {
      nixpkgs.to.path = pkgsets.nixpkgs;
      unstable.to.path = pkgsets.unstable;
    };
  };

  nixpkgs = {
    config = import ../shared/nixpkgs.nix;
    # TODO: Stick construct overlays in `flake.nix` and stick them in the
    # module args (or something).
    overlays = [ ];
  };
}
