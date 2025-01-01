{ inputs, lib, ... }:
{
  imports = [
    inputs.home.darwinModules.home-manager

    ./apps
    ./apps/personal.nix
    ./settings.nix
  ];

  # TODO: Factor this out to a module that can define the config location
  # in a way that can be addressed from both macOS & NixOS.
  environment.darwinConfig = lib.mkDefault "/etc/nix-darwin";
  system.stateVersion = 5;
}
