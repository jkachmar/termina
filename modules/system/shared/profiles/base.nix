{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.profiles.base;
in
{
  options.profiles.base = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "base profile for all systems";
      default = true;
    };

    configLocation = lib.mkOption {
      type = lib.types.oneOf [
        lib.types.path
        lib.types.str
      ];
      description = "default location for this config; varies between NixOS & macOS";
      default = if isDarwin then "/etc/nix-config" else /etc/nixos;
    };
  };

  config = lib.mkIf cfg.enable {
    # Useful programs (and aliases) to enable globally.
    programs.fish.enable = true;
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      bat
      btop
      fd
      git
      ripgrep
      vim
    ];
  };
}
