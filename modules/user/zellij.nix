{
  config,
  lib,
  unstable,
  ...
}: let
  inherit (lib) types;
  cfg = config.programs.zellij;
in {
  programs.zellij = lib.mkIf cfg.enable {
    settings = {
      theme = "gruvbox-light";
    };
  };
}
