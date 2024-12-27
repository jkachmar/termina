{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.git;
in
{
  programs.git = lib.mkIf cfg.enable {
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.default = "simple";
      rerere.enabled = true;
    };
  };
}
