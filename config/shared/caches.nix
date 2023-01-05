rec {
  caches = [
    # NixOS default cache.
    {
      url = "https://cache.nixos.org";
      key = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    }
  ];
  substituters = builtins.map (cache: cache.url) caches;
  trusted-public-keys = builtins.map (cache: cache.key) caches;
}
