{ config, lib, ... }:
let
  baseProfile = config.profiles.base;
in
lib.mkMerge [
  (lib.mkIf baseProfile.enable {
    environment.darwinConfig = lib.mkDefault baseProfile.configLocation;
  })
]
