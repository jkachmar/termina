# Copied from https://github.com/hawkw/flake/blob/c711f66125ff0b1c9fb832fe0ca9b3e5ae55523e/modules/nixos/profiles/docs.nix
{
  config,
  lib,
  ...
}:
let
  cfg = config.profiles.docs;
in
{
  config = lib.mkIf cfg.enable {
    documentation = {
      # Generate manpage index caches to enable searching using 'man -k'.
      man.generateCaches = true;

      # Enable packages' developer documentation.
      dev.enable = true;

      # Install nixos' own documentation.
      nixos.enable = true;
    };
  };
}
