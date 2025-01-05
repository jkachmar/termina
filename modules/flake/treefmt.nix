{ inputs, ... }:
{
  imports = [ inputs.treefmt.flakeModule ];
  perSystem.treefmt = {
    # Globally exclude the following patterns from formatting:
    settings.global.excludes = [
      # ...jujutsu's VCS tracking directory
      ".jj/*"
      # ...all markdown files
      "*.md"
      # ...all image files
      "*.jpg"
      "*.png"
    ];
    # Search for the `flake.nix` file to determine the project root directory.
    projectRootFile = "flake.nix";
    programs.nixfmt.enable = true;
  };
}
