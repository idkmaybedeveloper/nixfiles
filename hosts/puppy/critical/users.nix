{ config, ... }:

{
  users.users.lain = {
    hashedPasswordFile = config.sops.secrets.lain_password.path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4crBPBT98pQTOOl7frvoA5pxtRXEke/R5RaBTaGumw lain@m68k"
    ];
  };
}
