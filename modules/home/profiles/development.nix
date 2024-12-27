{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.targetPlatform) isDarwin;
  cfg = config.profiles.development;
in
{
  options.profiles.development.enable = lib.mkEnableOption "generic software development profile";

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        libvterm-neovim
        nixpkgs-fmt
        shellcheck
      ]
      ++ lib.optionals isDarwin [
        darwin.iproute2mac
      ];

    programs = {
      jq.enable = true;
      nix-index.enable = true;

      direnv = {
        enable = true;
        nix-direnv.enable = true;

        # Conditionally enable direnv integration for shells that home-manager manages.
        enableBashIntegration = config.programs.bash.enable;
        enableZshIntegration = config.programs.zsh.enable;
      };
    };
  };
}
