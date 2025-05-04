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
      # ...yaml files
      "*.yaml"
      "*.yml"
    ];
    # Search for the `flake.nix` file to determine the project root directory.
    projectRootFile = "flake.nix";
    programs.nixfmt.enable = true;
    # 'smartd' deliberately structures its comments so as to explain what some
    # tricky command line options are doing; `nixfmt` completely mangles this.
    settings.formatter.nixfmt.excludes = [ "modules/system/nixos/mixins/services/smartd.nix" ];
  };
}
