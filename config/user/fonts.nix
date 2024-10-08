{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Icon fonts.
    emacs-all-the-icons-fonts
    font-awesome_5

    # "Actual" fonts.
    hack-font
    ibm-plex
    jetbrains-mono
    overpass

    # Various fonts with nerd symbols.
    #
    # NOTE: Try to keep this in-line with fonts from the above list of
    # "actual" fonts.
    #
    # cf. https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix
    (nerdfonts.override {
      fonts = [
        "Hack"
        "IBMPlexMono"
        "JetBrainsMono"
        "NerdFontsSymbolsOnly"
        "Overpass"
      ];
    })
  ];
}
