{
  config,
  pkgs,
  abs,
  ...
}:

let
  endpoints = import (abs "lib/mihomo-endpoints.nix");

  # mihomo keeps geoip.dat/geosite.dat here and refreshes them on its own :3
  stateDir = "/var/lib/mihomo";

  puppySecret = name: {
    inherit name;
    value.sopsFile = abs "secrets/puppy.yaml";
  };

  ph = config.sops.placeholder;

  settings = import (abs "lib/mihomo-client.nix") { inherit ph endpoints; };
in
{
  sops.secrets = builtins.listToAttrs (
    map puppySecret [
      "reality_server_name"
      "mihomo_vless_uuid"
      "mihomo_reality_public_key"
      "mihomo_reality_short_id"
      "mihomo_hysteria_password"
    ]
  );

  sops.templates."mihomo-client.yaml".content = builtins.toJSON settings;

  launchd.daemons.mihomo = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.mihomo}/bin/mihomo"
        "-d"
        stateDir
        "-f"
        config.sops.templates."mihomo-client.yaml".path
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/mihomo.log";
      StandardErrorPath = "/tmp/mihomo.err.log";
    };
  };

  system.activationScripts.postActivation.text = ''
    install -d -m 0750 ${stateDir}
  '';

  environment.systemPackages = [ pkgs.mihomo ];
}