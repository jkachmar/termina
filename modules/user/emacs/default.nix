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
    package = pkgs.emacs; # 29.x
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
