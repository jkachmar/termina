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
      inherit system;
      specialArgs = { inherit inputs self; };
      modules = [
        {
          # TODO: Abstract this out so it's set by some function that discovers
          # the configuration by name in the 'machines' directory.
          networking.hostName = "moros";
          nixpkgs.hostPlatform = lib.mkDefault system;
          home-manager = {
            useGlobalPkgs = lib.mkDefault true;
            useUserPackages = lib.mkDefault true;
          };
        }
        ./system.nix
      ];
    }
  );
}
