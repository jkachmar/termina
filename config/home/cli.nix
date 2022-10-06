#############################
# OS-agnostic system tools. #
#############################
{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) optionals;
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;

  gcoreutils = pkgs.coreutils.override {
    singleBinary = false;
    withPrefix = true;
  };
in {
  home.packages = with pkgs;
    [
      # Misc. common programs without a better place to go.
      alejandra
      curl
      fd
      findutils
      libvterm-neovim
      nix-index
      ripgrep
      shellcheck
      wget
    ]
    ++ optionals isDarwin [
      gcoreutils
    ];
}
