{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  accountCfg = config.jk.account;
  cfg = config.jk.utils;
in
{
  options.jk.utils.enable = lib.mkEnableOption "common system-level utilities & config options";

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
