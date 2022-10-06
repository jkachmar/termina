{config, ...}: let
  name = "jkachmar";
  secretAgentDataPath = "/Users/${name}/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data";
  secretAgentPubKeysPath = "${secretAgentDataPath}/PublicKeys";
in
{
  imports = [
    ../../modules/home/primary-user.nix
    ../../config/home
  ];
  primary-user = {
    name = "jkachmar";
  };
}
