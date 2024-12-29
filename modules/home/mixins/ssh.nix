{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.programs.ssh;
in
{
  programs.ssh = lib.mkIf (cfg.enable && isDarwin) {
    extraConfig = ''
      AddKeysToAgent yes
      UseKeychain yes
    '';
    extraOptionOverrides = {
      IgnoreUnknown = "AddKeysToAgent,UseKeychain";
    };
  };
}
