##############################################################################
# OS-agnostic configuration options for the system's primary account holder. #
##############################################################################
{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  inherit (lib) mkAliasOptionModule mkDefault mkIf mkOption types;
  inherit (pkgs.stdenv.targetPlatform) isDarwin;
  cfg = config.primary-user;
in {
  options.primary-user.name = mkOption {
    type = types.nullOr types.str;
    default = null;
    description = "The primary account holder's username.";
  };

  options.primary-user.home = mkOption {
    type = types.nullOr types.str;
    default =
      if isDarwin
      then "/Users/${cfg.name}"
      else "/home/${cfg.name}";
    description = "The primary account holder's home directory.";
  };

  # Convenience aliases for various configuration options relating to the
  # system's primary account holder.
  #
  # NOTE: These aliases _must_ be OS-agnostic; this module will be imported by
  # OS-specific modules which will provide the config implementation as well as
  # any additional OS-specific options/aliases.
  imports = [
    # OS-agnostic option aliases.
    (mkAliasOptionModule ["primary-user" "user"] ["users" "users" cfg.name])
    (mkAliasOptionModule ["primary-user" "description"] ["users" "users" cfg.name "description"])
    (mkAliasOptionModule ["primary-user" "uid"] ["users" "users" cfg.name "uid"])
    (mkAliasOptionModule ["primary-user" "shell"] ["users" "users" cfg.name "shell"])
    # OS-agnostic `home-manager` option aliases.
    (mkAliasOptionModule [ "primary-user" "home-manager" ] [ "home-manager" "users" cfg.name ])
  ];

  config = mkIf (cfg.name != null) {
    home-manager.useGlobalPkgs = lib.mkDefault true;
    home-manager.useUserPackages = lib.mkDefault true;
    users.users.${cfg.name} = {
      name = cfg.name;
      home = cfg.home;
      uid = mkDefault 1000;
    };
  };
}
