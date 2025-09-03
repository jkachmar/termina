{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  options.nix.systemConfigLocation = lib.mkOption {
    type = lib.types.oneOf [
      lib.types.path
      lib.types.str
    ];
    description = "default location for the system config flake; varies between NixOS & macOS";
    default = if isDarwin then "/etc/nix-darwin" else /etc/nixos;
  };
}
