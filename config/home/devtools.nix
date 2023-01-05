#############################
# OS-agnostic system tools. #
#############################
{
  config,
  lib,
  pkgs,
  unstable,
  ...
}: let
  inherit (lib) optionals;
  inherit (pkgs.stdenv.targetPlatform) isDarwin isLinux;

  gcoreutils = pkgs.coreutils.override {
    singleBinary = false;
    withPrefix = true;
  };
in {
  home.packages =
    (with pkgs;
      [
        # Misc. common programs without a better place to go.
        alejandra
        curl
        fd
        findutils
        libvterm-neovim
        nix-index
        ripgrep
        shellcheck
        starship # XXX: unclear why this is necessary; it's enabled below too.
        wget
      ]
      ++ optionals isDarwin [
        gcoreutils
      ])
    ++ (with unstable; []);

  programs = {
    bash.enable = true;
    fish.enable = true;
    zsh.enable = true;

    bat = {
      enable = true;
      config.theme = "ansi";
    };

    htop = {
      enable = true;
      settings = {
        hide_userland_threads = true;
        highlight_base_name = true;
        show_program_path = false;
        tree_view = true;
        vim_mode = true;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;

      # Conditionally enable direnv integration for shells that home-manager manages.
      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };

    git = {
      enable = true;
      extraConfig = {
        core.editor = "vim";
        init.defaultBranch = "main";
        pull.rebase = true;
        push.default = "simple";
        rerere.enabled = true;
      };
    };

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
  };
}
