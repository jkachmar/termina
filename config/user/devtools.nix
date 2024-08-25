#############################
# OS-agnostic system tools. #
#############################
{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (lib) mkIf mkMerge optionals;
  inherit (pkgs.buildPlatform) isDarwin isLinux;

  gcoreutils = pkgs.coreutils.override {
    singleBinary = false;
    withPrefix = true;
  };
in
{
  home.packages =
    (
      with pkgs;
      [
        # Misc. common programs without a better place to go.
        alejandra
        curl
        fd
        findutils
        jq
        libvterm-neovim
        nix-index
        rsync
        shellcheck
        starship # XXX: unclear why this is necessary; it's enabled below too.
        wget
      ]
      ++ optionals isDarwin [
        darwin.iproute2mac
        gcoreutils
      ]
    )
    ++ (with unstable; [
      ripgrep
    ]);

  programs = {
    bash.enable = true;
    btop.enable = true;

    fish = {
      enable = true;
      shellInit = ''
        # Disable greeting text.
        set -g fish_greeting
      '';
    };

    zsh = mkMerge [
      { enable = true; }
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

    direnv = {
      enable = true;
      nix-direnv.enable = true;

      # Conditionally enable direnv integration for shells that home-manager manages.
      enableBashIntegration = config.programs.bash.enable;
      enableZshIntegration = config.programs.zsh.enable;
    };

    fzf = {
      enable = true;
      # Conditionally enable 'fzf' integration for interactive shells managed
      # via home-manager.
      enableBashIntegration = config.programs.bash.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableZshIntegration = config.programs.zsh.enable;
      tmux.enableShellIntegration = config.programs.tmux.enable;
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

    tmux = {
      enable = true;
      keyMode = "vi";
    };
  };
}
