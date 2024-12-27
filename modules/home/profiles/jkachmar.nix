{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (pkgs.hostPlatform) isDarwin;
  cfg = config.profiles.jkachmar;
in
{
  options.profiles.jkachmar = {
    enable = lib.mkEnableOption "jkachmar's user profile";

    username = lib.mkOption {
      type = lib.types.str;
      default = "jkachmar";
      description = "jkachmar's username.";
    };

    home = lib.mkOption {
      type = lib.types.str;
      default = if isDarwin then "/Users/${cfg.username}" else "/home/${cfg.username}";
      description = "jkachmar's home directory.";
    };

    git = {
      username = lib.mkOption {
        type = lib.types.str;
        default = cfg.username;
        description = "jkachmar's git username";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = "git@jkachmar.com";
        description = "jkachmar's git email address";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.username = lib.mkDefault cfg.username;
      home.homeDirectory = lib.mkDefault cfg.home;
      # By default, allow `home-manager` to manage its own installation.
      programs.home-manager.enable = lib.mkDefault true;
    })
    (lib.mkIf (cfg.enable && config.programs.git.enable) {
      programs.git = {
        userName = lib.mkDefault cfg.git.username;
        userEmail = lib.mkDefault cfg.git.email;
      };
    })
  ];
}
