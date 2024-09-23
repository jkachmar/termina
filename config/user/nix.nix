{
  lib,
  pkgs,
  pkgsets,
  ...
}:
let
  inherit (lib) mkIf mkMerge;
  inherit (pkgs.buildPlatform) isDarwin isAarch64;
  inherit (import ../shared/caches.nix) substituters trusted-public-keys;
in
{
  nix = {
    enable = true;
    # XXX: Workaround for a conflict between `nix-darwin` & `home-manager` both
    # trying to set `home-manager.${user}.nix.package` when both this & the
    # system-level `nix.package` are set.
    #
    # NOTE: `mkOverride 1000` is equivalent to `mkDefault`, but calling it
    # explicitly serves as a reminder that this _isn't_ constructing a default
    # value for the module system so much as it is working around an edge case.
    #
    # NOTE: Setting this explicitly is necessary to get 'home-manager' to
    # generate Nix settings under '$XDG_CONFIG_HOME'.
    package = lib.mkOverride 1000 pkgs.nix;
    settings = mkMerge [
      {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        inherit substituters trusted-public-keys;
      }
      # NOTE: This should allow ARM-based macOS targets to build x86 software
      # by way of Rosetta.
      (mkIf (isDarwin && isAarch64) {
        extra-platforms = [
          "aarch64-darwin"
          "x86_64-darwin"
        ];
      })
    ];

    # FIXME: Duplicated; see system-level Nix config.
    registry = {
      nixpkgs.to = {
        type = "path";
        path = pkgsets.nixpkgs;
      };
      unstable.to = {
        type = "path";
        path = pkgsets.unstable;
      };
    };
  };
}
