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
  inherit (lib) mkIf mkMerge optionals;
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
    fish = mkMerge [
      {enable = true;}
      # Fixes a bug where fish shell doesn't properly set up the PATH on macOS.
      #
      # FIXME: Looks like a clean reinstall of Nix should fix this now that the
      # installer provides a fish config.
      #
      # cf. https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1299764109
      (mkIf isDarwin {
        loginShellInit = ''
          fish_add_path --move --prepend --path \
            ${config.primary-user.home}/.nix-profile/bin \
            /etc/profiles/per-user/${config.primary-user.name}/bin \
            /run/current-system/sw/bin \
            /nix/var/nix/profiles/default/bin
        '';
      })
    ];
    zsh = mkMerge [
      {enable = true;}
      # NOTE: macOS version upgrades reset '/etc/zshrc', which means that the
      # shell no longer "knows" how to source all Nix-related stuff.
      #
      # Hopefully this is a reasonable workaround, but if not then switching to
      # 'fish' works in a pinch (i.e. how i've avoided running into this
      # problem on other macOS machines so far).
      #
      # cf. https://discourse.nixos.org/t/nix-commands-missing-after-macos-12-1-version-upgrade/16679
      (mkIf isDarwin {
        initExtraFirst = ''
          # Nix
          if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          fi
          # End Nix
        '';
      })
    ];

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
