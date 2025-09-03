{ inputs, ... }:
{
  imports = [
    inputs.nixpkgs.nixosModules.notDetected
  ];
}
