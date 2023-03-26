############################################################################
# OS-agnostic home config options for the system's primary account holder. #
############################################################################
{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib) mkAliasDefinitions mkAliasOptionModule mkIf mkOption types;
  inherit (pkgs.buildPlatform) isDarwin;
  cfg = config.primary-user;
in {
  options.primary-user.name = mkOption {
    type = types.nullOr types.str;
    default = "jkachmar";
    description = "The primary account holder's username (defaults to 'jkachmar').";
  };

  options.primary-user.home = mkOption {
    type = types.nullOr types.str;
    default =
      if isDarwin
      then "/Users/${cfg.name}"
      else "/home/${cfg.name}";
    description = "The primary account holder's home directory.";
  };

  options.primary-user.git.user.name = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "The primary account holder's global git user name.";
  };

  options.primary-user.git.user.email = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "The primary account holder's global git email address.";
  };

  config = mkIf (cfg.name != null) {
    home.username = cfg.name;
    home.homeDirectory = cfg.home;
    home.stateVersion = lib.mkDefault "22.11";

    # By default, allow `home-manager` to manage its own installation.
    programs.home-manager.enable = lib.mkDefault true;
    programs.git = {
      userName = mkAliasDefinitions options.primary-user.git.user.name;
      userEmail = mkAliasDefinitions options.primary-user.git.user.email;
    };
  };
}
