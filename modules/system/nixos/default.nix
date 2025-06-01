{ inputs, lib, ... }:
{
  imports = [
    # Pull all the OS-agnostic modules, so macOS hosts can just import this as
    # their configuration entrypoint.
    ../common
    inputs.nixpkgs.nixosModules.notDetected
    inputs.disko.nixosModules.disko
    ./mixins
    ./profiles
  ];

  system.stateVersion = lib.mkDefault "25.05";
}
