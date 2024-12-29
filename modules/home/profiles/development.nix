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
      # Let's try 'hx' as the default editor.
      helix = {
        enable = true;
        defaultEditor = true;
      };

      jujutsu.enable = true;
      # FIXME: Some more SSH identity stuff probably needs to get set up...
      gpg.enable = true;
      ssh.enable = true;

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
