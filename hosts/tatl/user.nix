{ config, ... }:
{
  imports = [
    ../../profiles/user/base.nix
    ../../profiles/user/development.nix
  ];
}
