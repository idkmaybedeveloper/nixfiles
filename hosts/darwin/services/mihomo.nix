{
  config,
  pkgs,
  abs,
  ...
}:

let
  endpoints = import (abs "lib/mihomo-endpoints.nix");

  # mihomo reads geoip.dat/geosite.dat out of its working dir (-d)
  stateDir = "/var/lib/mihomo";

  puppySecret = name: {
    inherit name;
    value.sopsFile = abs "secrets/puppy.yaml";
  };

  ph = config.sops.placeholder;

  settings = import (abs "lib/mihomo-client.nix") {
    inherit ph endpoints;
    offlineGeodata = true;
  };

  configPath = config.sops.templates."mihomo-client.yaml".path;

  mihomoDaemon = pkgs.writeShellScript "mihomo-daemon" ''
    for _ in $(seq 1 60); do
      [ -r ${configPath} ] && break
      sleep 1
    done
    exec ${pkgs.mihomo}/bin/mihomo -d ${stateDir} -f ${configPath}
  '';
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
        "/bin/sh"
        "${mihomoDaemon}"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      # sops has no restartUnits on darwin, so let launchd notice the rewrite
      WatchPaths = [ configPath ];
      StandardOutPath = "/tmp/mihomo.log";
      StandardErrorPath = "/tmp/mihomo.err.log";
    };
  };

  system.activationScripts.postActivation.text = ''
    install -d -m 0750 ${stateDir}
    install -m 0644 ${pkgs.v2ray-geoip}/share/v2ray/geoip.dat ${stateDir}/geoip.dat
    install -m 0644 ${pkgs.v2ray-domain-list-community}/share/v2ray/geosite.dat ${stateDir}/geosite.dat
  '';

  environment.systemPackages = [ pkgs.mihomo ];
}