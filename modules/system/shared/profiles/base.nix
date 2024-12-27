{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.base;
in
{
  options.profiles.base = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "base profile for all systems";
      default = true;
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
