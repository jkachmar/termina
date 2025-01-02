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
  cfg = config.jk.account;
in
{
  options.jk.account = {
    enable = lib.mkEnableOption "my user account";

    username = lib.mkOption {
      type = lib.types.str;
      default = "jkachmar";
      description = "my username";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = if isDarwin then "/Users/${cfg.username}" else "/home/${cfg.username}";
      description = "my home directory";
    };

    configLocation = lib.mkOption {
      type = lib.types.oneOf [
        lib.types.path
        lib.types.str
      ];
      description = "default location for this config; varies between NixOS & macOS";
      default = if isDarwin then "/etc/nix-darwin" else /etc/nixos;
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "my auxiliary groups (no-op on macOS)";
    };

    isNormalUser = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "whether my account is for 'real' user (no-op on macOS)";
    };
  };

  imports = [
    (lib.mkAliasOptionModule [ "jk" "account" "uid" ] [ "users" "users" cfg.username "uid" ])
    (lib.mkAliasOptionModule [ "jk" "account" "gid" ] [ "users" "groups" cfg.username "gid" ])
  ];

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      jk.account = {
        # default group ID for the first macOS account is 501.
        uid = lib.mkDefault (if isDarwin then 501 else 1000);
        gid = lib.mkDefault 1000;
      };

      users.users."${cfg.username}" = {
        name = cfg.username;
        home = cfg.homeDirectory;
      };
    })

    (lib.mkIf (cfg.enable && config.jk.nix.enable) {
      nix.settings = {
        allowed-users = [ cfg.username ];
        trusted-users = [ cfg.username ];
      };
    })
  ];
}
