{ config, lib, ... }:

{
  users.users.lain = {
    hashedPasswordFile = config.sops.secrets.lain_password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4crBPBT98pQTOOl7frvoA5pxtRXEke/R5RaBTaGumw lain@m68k"
    ];
  };

  # srvos server turns this off; puppy is on the open internet and lain has a
  # password from sops anyway
  security.sudo.wheelNeedsPassword = lib.mkForce true;
}
