{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  cfg = config.profiles.base;
in
{
  options.profiles.base = {
    enable = (lib.mkEnableOption "base system profile") // {
      default = true;
    };

    configLocation = lib.mkOption {
      type = lib.types.oneOf [
        lib.types.path
        lib.types.str
      ];
      description = "default location for this config; varies between NixOS & macOS";
      default = if isDarwin then "/etc/nix-darwin" else /etc/nixos;
    };
  };

  config = lib.mkIf cfg.enable {
    # Useful programs to enable globally.
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
