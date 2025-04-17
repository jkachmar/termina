{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.utils;
in
{
  options.profiles.utils.enable = (lib.mkEnableOption "common system utilities") // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
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
