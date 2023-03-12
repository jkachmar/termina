{
  homebrew = {
    enable = true;

    global.autoUpdate = true;
    onActivation = {
      cleanup = "zap";
      upgrade = true;
    };

    taps = ["homebrew/cask"];

    brews = [];
    casks = [
      "balenaetcher" # USB drive imager.
      "discord" # Nerd chat.
      "element" # Nerdier chat.
      "firefox" # A good web browser.
      "iterm2" # A terminal emulator with font rendering & tmux support.
      "itsycal" # Titlebar calendar.
      "keepassxc" # 1Password keeps getting worse...
      "secretive" # Secure Enclave SSH key & identity management.
      # "sensiblesidebuttons" # Make the back buttons go... back?
      "signal" # Secret chat.
      # "virtualbox" # Virtualization (duh).
      # "virtualbox-extension-pack" # Virtualization helpers.
      "zotero" # Research paper catalog & organizer.
    ];

    # Mac App Store applications.
    #
    # NOTE: Use the `mas` CLI to search for the number associated with a given
    # application name.
    #
    # e.g. `mas search 1Password`
    masApps = {
      "Slack" = 803453959;
      "Strongbox Pro" = 1481853033;
      "Wireguard" = 1451685025;
    };
  };
}
