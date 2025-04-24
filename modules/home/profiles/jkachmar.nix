{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.hostPlatform) isDarwin;
  cfg = config.profiles.jkachmar;
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

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = if isDarwin then "/Users/${cfg.username}" else "/home/${cfg.username}";
      description = "my primary account's home directory";
    };
  };
  config = lib.mkIf cfg.enable {
    home = {
      inherit (cfg) username homeDirectory;
    };
  };
}
