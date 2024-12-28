{
  config,
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.profiles.jkachmar;
in
{
  options.profiles.jkachmar = {
    enable = lib.mkEnableOption "jkachmar's profile";

    username = lib.mkOption {
      type = lib.types.str;
      default = "jkachmar";
      description = "jkachmar's username";
    };

    home = lib.mkOption {
      type = lib.types.str;
      default = if isDarwin then "/Users/${cfg.username}" else "/home/${cfg.username}";
      description = "jkachmar's home directory";
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "user's auxiliary groups; no-op on macOS";
    };

    isNormalUser = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "whether the account is for a 'real' user; no-op on macOS";
    };
  };

  imports = [
    (lib.mkAliasOptionModule [ "profiles" "jkachmar" "uid" ] [ "users" "users" cfg.username "uid" ])
    (lib.mkAliasOptionModule [ "profiles" "jkachmar" "gid" ] [ "users" "groups" cfg.username "gid" ])
    (lib.mkAliasOptionModule
      [ "profiles" "jkachmar" "home-manager" ]
      [ "home-manager" "users" "jkachmar" ]
    )
    (lib.mkAliasOptionModule
      [ "profiles" "jkachmar" "openssh" ]
      [ "users" "users" "jkachmar" "openssh" ]
    )
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      profiles.jkachmar = {
        uid = lib.mkDefault 1000;
        gid = lib.mkDefault 1000;
      };
      home-manager.extraSpecialArgs = {
        inherit inputs unstable;
      };
      users.users."${cfg.username}" = {
        name = cfg.username;
        home = cfg.home;
      };
      nix.settings = {
        allowed-users = [ cfg.username ];
        trusted-users = [ cfg.username ];
      };
    })
  ];
}
