{ config, abs, ... }:

let
  wgSecret = name: {
    inherit name;
    value = {
      sopsFile = abs "secrets/alphys-wireguard.yaml";
      restartUnits = [ "wg-quick-mrrp.service" ];
    };
  };
in
{
  sops.secrets = builtins.listToAttrs (
    map wgSecret [
      "wg-mrrp-private-key"
      "wg-mrrp-preshared-key"
    ]
  );

  systemd.services.wg-quick-mrrp.conflicts = [ "mihomo.service" ];

  networking.wg-quick.interfaces.mrrp = {
    address = [ "10.7.0.227/32" ];
    dns = [ "10.7.0.1" ];
    privateKeyFile = config.sops.secrets."wg-mrrp-private-key".path;
    peers = [
      {
        publicKey = "6dkW1MiOFtPGpnMhVwN+87oTFl7KkuUDN63vfet/Rzo=";
        presharedKeyFile = config.sops.secrets."wg-mrrp-preshared-key".path;
        endpoint = "87.228.126.114:51820";
        allowedIPs = [ "0.0.0.0/0" ];
        persistentKeepalive = 25;
      }
    ];
  };
}
