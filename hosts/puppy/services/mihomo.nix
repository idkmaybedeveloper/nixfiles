{
  config,
  lib,
  pkgs,
  wildcardCert,
  ...
}:

let
  # systemd drops LoadCredential= here, which is the only way a DynamicUser
  # service with ProtectSystem=strict gets to read the cert dir
  creds = "/run/credentials/mihomo.service";

  # 80/443 belong to angie and stay a plain boring website...
  vlessPort = 46207;
  hysteriaPort = 16022;

  settings = {
    log-level = "info";
    ipv6 = false;
    mode = "rule";
    unified-delay = true;

    listeners = [
      {
        name = "vless-reality";
        type = "vless";
        listen = "0.0.0.0";
        port = vlessPort;
        users = [
          {
            username = "lain";
            uuid = config.sops.placeholder.mihomo_vless_uuid;
            flow = "xtls-rprx-vision";
          }
        ];
        reality-config = {
          dest = "127.0.0.1:443";
          server-names = [ config.sops.placeholder.reality_server_name ];
          private-key = config.sops.placeholder.mihomo_reality_private_key;
          short-id = [ config.sops.placeholder.mihomo_reality_short_id ];
        };
      }
      {
        name = "hysteria2";
        type = "hysteria2";
        listen = "0.0.0.0";
        port = hysteriaPort;
        users.lain = config.sops.placeholder.mihomo_hysteria_password;
        certificate = "${creds}/cert.pem";
        private-key = "${creds}/key.pem";
        alpn = [ "h3" ];
        up = "200 mbps";
        down = "200 mbps";
        masquerade = "http://127.0.0.1:80";
      }
    ];

    proxies = [ ];
    rules = [
      "IP-CIDR,127.0.0.0/8,REJECT,no-resolve"
      "IP-CIDR,10.0.0.0/8,REJECT,no-resolve"
      "IP-CIDR,172.16.0.0/12,REJECT,no-resolve"
      "IP-CIDR,192.168.0.0/16,REJECT,no-resolve"
      "IP-CIDR,169.254.0.0/16,REJECT,no-resolve"
      "MATCH,DIRECT"
    ];
  };
in
{
  sops.secrets.mihomo_vless_uuid = { };
  sops.secrets.mihomo_reality_private_key = { };
  sops.secrets.mihomo_reality_short_id = { };
  sops.secrets.mihomo_hysteria_password = { };
  sops.secrets.reality_server_name = { };

  sops.templates."mihomo.yaml".content = builtins.toJSON settings;

  services.mihomo = {
    enable = true;
    configFile = config.sops.templates."mihomo.yaml".path;
  };

  systemd.services.mihomo = {
    serviceConfig = {
      LoadCredential = lib.mkForce [
        "config.yaml:${config.sops.templates."mihomo.yaml".path}"
        "cert.pem:${wildcardCert.fullchain}"
        "key.pem:${wildcardCert.key}"
      ];

      # the upstream module zeroes these out, but we bind 443
      AmbientCapabilities = lib.mkForce "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = lib.mkForce "CAP_NET_BIND_SERVICE";
    };
  };

  # for `mihomo generate uuid` / `mihomo generate reality-keypair`
  environment.systemPackages = [ pkgs.mihomo ];

  networking.firewall.allowedTCPPorts = [ vlessPort ];
  networking.firewall.allowedUDPPorts = [ hysteriaPort ];
}