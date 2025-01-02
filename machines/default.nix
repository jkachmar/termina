{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.darwinConfigurations = lib.genAttrs [ "moros" "prometheus" ] (
    hostname:
    withSystem "aarch64-darwin" (
      {
        pkgs,
        unstable,
        system,
        ...
      }:
      inputs.darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs self unstable; };
        modules = [
          {
            networking.hostName = hostname;
            nixpkgs.hostPlatform = lib.mkDefault system;
          }
          ./${hostname}/system.nix
        ];
      }
    )
  );
}
