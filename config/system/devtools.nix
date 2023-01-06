{
  # Ensure that all common shells are enabled & managed by Nix.
  programs = {
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;
  };
}
