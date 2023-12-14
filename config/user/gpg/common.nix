{...}: {
  programs.gpg = {
    enable = true;
    scdaemonSettings = {disable-ccid = true;};
  };
}
