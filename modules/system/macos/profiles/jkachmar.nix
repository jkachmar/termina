{ config, lib, ... }:
let
  cfg = config.profiles.jkachmar;
  nixCfg = config.profiles.nix;
in
{
  options.profiles.jkachmar = {
    enable = (lib.mkEnableOption "jkachmar's user profile") // {
      default = true;
    };

    username = lib.mkOption {
      type = lib.types.str;
      default = "jkachmar";
      description = "my primary account's username";
    };
  };

  imports = [
    (lib.mkAliasOptionModule
      [ "profiles" "users" "jkachmar" "home" ]
      [ "users" "users" cfg.username "home" ]
    )
  ];

  config = lib.mkIf cfg.enable {
    system.primaryUser = cfg.username;
    users.users.${cfg.username} = {
      name = cfg.username;
      uid = 501; # 501 is the default gid for the first macOS account.
      home = "/Users/${cfg.username}";
    };
    nix.settings = lib.mkIf nixCfg.enable {
      allowed-users = [ cfg.username ];
      trusted-users = [ cfg.username ];
    };
  };
}
