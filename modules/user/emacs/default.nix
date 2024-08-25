{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (lib) types;
  cfg = config.programs.emacs;
in
lib.mkIf cfg.enable {
  # for 'org-roam'
  home.packages = [pkgs.graphviz];
  programs.emacs = {
    # 29.x not yet in stable branch
    package = unstable.emacs;
    extraPackages =
      epkgs:
      builtins.attrValues {
        inherit (epkgs)
          emacsql
          emacsql-sqlite
          vterm
          ;
      };
  };
}
