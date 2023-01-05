{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (pkgs.stdenv.targetPlatform) isDarwin isAarch64;
  inherit (import ../common/caches.nix) substituters trusted-public-keys;

in {
  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    settings = mkMerge [
      {
        experimental-features = ["nix-command" "flakes"];
        inherit substituters trusted-public-keys;
      }
      # NOTE: This should allow ARM-based macOS targets to build x86 software
      # by way of Rosetta.
      (mkIf (isDarwin && isAarch64) {
        extra-platforms = ["aarch64-darwin" "x86_64-darwin"];
      })
    ];

    # FIXME: Duplicated; see system-level Nix config.
    registry = {
      nixpkgs.flake = if isDarwin then inputs.macosPkgs else inputs.nixosPkgs;
      unstable.flake = inputs.unstable;
    };
  };
}
