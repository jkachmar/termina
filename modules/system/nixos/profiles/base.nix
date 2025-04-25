{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.profiles.base;
in
{
  config = lib.mkIf cfg.enable {
    programs.git.enable = true;
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    # Don't install the '/lib/ld-linux.so.2 stub'; saves one instance of nixpkgs.
    environment.ldso32 = null;
    environment.systemPackages = with pkgs; [
      ghostty.terminfo
    ];

    # Use 'dbus-broker' impl; it's better than the default.
    #
    # Can be removed once 'dbus-broker' is the default impl.
    # cf. https://github.com/NixOS/nixpkgs/issues/299476
    services.dbus.implementation = "broker";

    # All these systems have at least one SSD.
    services.fstrim.enable = lib.mkDefault true;

    # Use Rust-based system switcher.
    system.switch = {
      enable = lib.mkDefault false;
      enableNg = lib.mkDefault true;
    };
  };
}
