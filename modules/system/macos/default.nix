{ config, ... }:
{
  imports = [
    # Pull all the OS-agnostic modules, so macOS hosts can just import this as
    # their configuration entrypoint.
    ../common
    # Expose all of the macOS mixins & profiles.
    ./mixins
    ./profiles
  ];

  environment.darwinConfig = config.profiles.nix.location;
  system.stateVersion = 6;
}
