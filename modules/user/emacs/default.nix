{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
lib.mkIf config.programs.emacs.enable {
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
