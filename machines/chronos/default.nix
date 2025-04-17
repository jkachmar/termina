{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.diskoConfigurations = {
    hrodreptus = import ./disks/hrodreptus.nix;
  };
  flake.nixosConfigurations.chronos = withSystem "x86_64-linux" (
    { unstable, system, ... }:
    {
      inherit system;
      specialArgs = { inherit inputs self unstable; };
      modules = [
        {
          networking.hostName = "chronos";
          nixpkgs.hostPlatform = system;
        }
        ./system.nix
      ];
    }
  );
}
