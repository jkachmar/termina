{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../profiles/nixos/server.nix
    ./hardware.nix
    ./networking.nix
    ./proxy.nix
    ./wireguard.nix
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];
  networking = {
    domain = "thempire.dev";
    enableIPv6 = false; # TODO: Figure out IPv6...
    wireguard.enable = true;
  };
  security.acme.enable = true;
  services = {
    ddclient = {
      enable = true;
      configFile = "/secrets/ddclient/config";
    };
    dnscrypt-proxy2.enable = true;
    homebridge.enable = true;
    linkding.enable = true;
    nginx.enable = true;
    pihole.enable = true;
    plex = {
      enable = true;
      hardwareAcceleration = true;
    };
    radarr.enable = true;
    sabnzbd.enable = true;
    sonarr.enable = true;
  };

  # TODO: Factor this out into a separate module.
  environment.persistence."/state/root".hideMounts = true;
  environment.etc."nixos".source = "${config.primary-user.home}/.config/dotfiles";
  microvm.host.enable = true;

  users = {
    mutableUsers = false;
    users.root.initialHashedPassword = "$y$j9T$LJP1N/s5kGR36Mf4EZduG1$U74tnkAfZC8UWSmttUZjwPrNlMgOcjgDdswK36cPWq3";
  };

  primary-user = {
    initialHashedPassword = "$y$j9T$J.Eb31b.9Gi4fS/lvcodk0$c4RHKee/cjn5AyhJo3HiXm1svt54l9MQ0SfWhy7fiz4";

    extraGroups = ["analytics" "downloads"];
    # TODO: Source this from an external file; keep in sync w/ all servers.
    openssh.authorizedKeys.keys = [
      # yubikey
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZJVgzxzU87/KHzc8u+RZot1/CHyW85zSC5jdlbDDUx openpgp:0xAAF3634A"

      # crazy-diamond
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF6xLftzyelmpJUdQPv4pf793s4JF1f/G1QuviDsFJzd jkachmar@crazy-diamond"

      # purple-haze
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBZcDYiijg9rjTJ8PkmEIbg8GeIcPh8cUAQTD2NWIis8CcVkPR9B5THM6OPAs2zps3/3HTzvNClBCHlhks/dVGE= purple-haze"

      # star-platinum
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJxSLTsCtr8JW1XgP+cqx6+iAI1VzJVjU/LR5nkNcEY star-platinum"

      # wonder-of-u
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCQ2KyPZfXYoVPVlRLNFUHIAWkmQ4Tgqlq7m6l0z5R8TgOmoV+2CyhEjHcUvUs6ra4O7ZjB3PwM+xCx/FtCX+I0= wonder-of-u"
    ];
  };
}
