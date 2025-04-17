{ config, ... }:
{
  imports = [
    # Pull all the OS-agnostic modules, so NixOS hosts can just import this as
    # their configuration entrypoint.
    ../common
  ];

  system.stateVersion = "24.11";
}
