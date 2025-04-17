{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.profiles.ssh;
in
{
  options.profiles.ssh.enable = lib.mkEnableOption "SSH user profile";

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.ssh = {
        enable = true;
        extraConfig = ''
          IdentityFile=~/.ssh/yubikey.pub
        '';
      };
    })
    (lib.mkIf (cfg.enable && isDarwin) {
      programs.ssh = {
        extraConfig = ''
          AddKeysToAgent yes
          UseKeychain yes
        '';
        extraOptionOverrides = {
          IgnoreUnknown = "AddKeysToAgent,UseKeychain";
        };
      };
    })
  ];
}
