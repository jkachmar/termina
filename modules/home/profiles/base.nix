{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.profiles.base;

  gcoreutils = pkgs.coreutils.override {
    singleBinary = false;
    withPrefix = true;
  };
in
{
  options.profiles.base.enable = lib.mkEnableOption "base profile for all users" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        curl
        rsync
        wget
      ]
      ++ lib.optionals isDarwin [
        findutils
        gcoreutils
      ];

    # Enable catppuccin themes for all programs that have options :3
    catppuccin = {
      enable = true;
      flavor = "frappe";
      # bat.enable = true;
      # fish.enable = true;
      # starship.enable = true;
      # tmux.enable = true;
    };

    programs = {
      bash.enable = true;
      fish.enable = true;
      zsh.enable = true;

      fd.enable = true;
      git.enable = true;
      jujutsu.enable = true;
      ripgrep.enable = true;

      bat.enable = true;

      starship = {
        enable = true;
        settings = {
          add_newline = false;
          line_break.disabled = true;
          username.show_always = true;
        };

        # Conditionally enable starship integration for shells that home-manager manages.
        enableBashIntegration = config.programs.bash.enable;
        enableFishIntegration = config.programs.fish.enable;
        enableZshIntegration = config.programs.zsh.enable;
      };

      tmux = {
        enable = true;
        keyMode = "vi";
      };
    };
  };
}
