{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.jk.account;
in
{
  options.jk.account = {
    enable = lib.mkEnableOption "my account";

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

    email = lib.mkOption {
      type = lib.types.str;
      default = "me@jkachmar.com";
      description = "my default email address";
    };
  };

  config = lib.mkIf cfg.enable {
    home.username = lib.mkDefault cfg.username;
    home.homeDirectory = lib.mkDefault cfg.homeDirectory;
    # By default, allow `home-manager` to manage its own installation.
    programs.home-manager.enable = lib.mkDefault true;
  };
}
