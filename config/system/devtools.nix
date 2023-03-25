{
  # Ensure that all common shells are enabled & managed by Nix.
  programs = {
    fish.enable = true;
    zsh.enable = true;
  };
}
