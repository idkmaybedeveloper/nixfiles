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

    templates."vivienne-config.toml" = {
      owner = "lain";
      content = ''
        server = "https://scrobble.cuddles.rs"
        username = "${config.sops.placeholder.vivienne_username}"
        password = "${config.sops.placeholder.vivienne_password}"
        api_key = "vivienne"
        shared_secret = ""
      '';
    };
  };

  services.vivienne = {
    enable = true;
    config = {
      username = "dummy";
      password = "dummy";
    };
  };

  launchd.user.agents.vivienne.serviceConfig.EnvironmentVariables.VIVIENNE_CONFIG =
    lib.mkForce
      config.sops.templates."vivienne-config.toml".path;
}
