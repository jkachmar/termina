########################################################################
# macOS configuration options for the system's primary account holder. #
########################################################################
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkDefault mkIf;
  cfg = config.primary-user;
in {
  # OS-agnostic options/aliases.
  imports = [../shared/primary-user.nix];
  # Define macOS-specific `primary-user` configuration.
  config = mkIf (cfg.name != null) {
    nix = {
      # Run the garbage collector as the primary-user.
      gc.user = cfg.name;
      # TODO: Should this use `lib.mkMerge` and _only_ specify the primary user
      # as an allowed and/or trusted user?
      settings.allowed-users = ["root" cfg.name "@admin" "@wheel"];
      settings.trusted-users = ["root" cfg.name "@admin" "@wheel"];
    };

    # Used for backwards compatibility, please read the changelog before
    # updating.
    #
    # $ darwin-rebuild changelog
    system.stateVersion = lib.mkDefault 4;
  };
}
