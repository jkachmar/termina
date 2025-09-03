{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.darwinConfigurations.moros = withSystem "aarch64-darwin" (
    {
      pkgs,
      unstable,
      system,
      ...
    }:
    inputs.darwin.lib.darwinSystem {
      specialArgs = { inherit inputs self unstable; };
      modules = self.internal.modules.darwin ++ [
        { nixpkgs.hostPlatform = system; }
        ./configuration.nix
      ];
    }
  );
}
