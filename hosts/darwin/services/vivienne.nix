{
  config,
  lib,
  pkgs,
  abs,
  ...
}:

{
  sops = {
    defaultSopsFile = abs "secrets/m68k.yaml";
    age.keyFile = "/Users/lain/.config/sops/age/keys.txt";

    secrets.vivienne_username = { };
    secrets.vivienne_password = { };
  };

  services.vivienne = {
    enable = true;
    config = {
      username_file = config.sops.secrets.vivienne_username.path;
      password_file = config.sops.secrets.vivienne_password.path;
    };
  };
}
