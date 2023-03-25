{
  config,
  inputs,
  lib,
  pkgs,
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
        "unstable=${inputs.unstable}"
      ]
      ++ lib.optionals isDarwin [
        "nixpkgs=${inputs.macosPkgs}"
        "darwin=${inputs.darwin}"
        "darwin-config=${darwinCfg}"
      ]
      ++ lib.optionals isLinux [
        "nixpkgs=${inputs.nixosPkgs}"
      ]);

    # FIXME: Duplicated; see user-level Nix config.
    registry = {
      nixpkgs.flake =
        if isDarwin
        then inputs.macosPkgs
        else inputs.nixosPkgs;
      unstable.flake = inputs.unstable;
    };
  };

  nixpkgs = {
    config = import ../shared/config.nix;
    # TODO: Stick construct overlays in `flake.nix` and stick them in the
    # module args (or something).
    overlays = [];
  };
}
