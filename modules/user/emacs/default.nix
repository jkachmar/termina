{
  config,
  lib,
  unstable,
  ...
}:
let
  inherit (lib) types;
  cfg = config.programs.emacs;
in
{
  programs.emacs = lib.mkIf cfg.enable {
    package =
      if unstable.stdenv.targetPlatform.isDarwin then unstable.emacsMacport else unstable.emacs; # 29.x not yet in stable branch
    extraPackages = epkgs: builtins.attrValues { inherit (epkgs) magit which-key; };
  };
}
