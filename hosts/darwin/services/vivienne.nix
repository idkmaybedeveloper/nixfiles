{
  config,
  lib,
  pkgs,
  abs,
  ...
}:

let
  tomlFormat = pkgs.formats.toml { };
  mkHome = "/Users/lain/.local/state/vivienne-mk";

  mkConfig = tomlFormat.generate "vivienne-mk-config.toml" {
    server = "https://fm.pooziqo.fun";
    username = "lain";
    password_file = config.sops.secrets.vivienne_mk_password.path;
    api_key = "vivienne";
    shared_secret = "";
  };
in
{
  sops = {
    defaultSopsFile = abs "secrets/m68k.yaml";
    age.keyFile = "/Users/lain/.config/sops/age/keys.txt";

    secrets.vivienne_username = {
      owner = "lain";
    };
    secrets.vivienne_password = {
      owner = "lain";
    };
    secrets.vivienne_mk_password = {
      owner = "lain";
    };
  };

  services.vivienne = {
    enable = true;
    config = {
      username_file = config.sops.secrets.vivienne_username.path;
      password_file = config.sops.secrets.vivienne_password.path;
    };
  };

  launchd.user.agents.vivienne-mk = {
    serviceConfig = {
      ProgramArguments = [ "${config.services.vivienne.package}/bin/vivienne" ];
      EnvironmentVariables = {
        VIVIENNE_CONFIG = "${mkConfig}";
        HOME = mkHome;
      };
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/vivienne-mk.log";
      StandardErrorPath = "/tmp/vivienne-mk.err.log";
    };
  };
}
