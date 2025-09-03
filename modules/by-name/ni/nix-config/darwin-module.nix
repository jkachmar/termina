{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.nix;
in
{
  config = {
    environment.darwinConfig = lib.mkDefault cfg.systemConfigLocation;
  };
}
