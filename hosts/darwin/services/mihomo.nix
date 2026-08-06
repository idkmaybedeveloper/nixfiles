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

  settings = {
    mixed-port = 7890;
    allow-lan = false;
    mode = "rule";
    log-level = "info";
    ipv6 = false;

    geodata-mode = true;
    geo-auto-update = true;
    geo-update-interval = 168;

    proxies = [
      {
        name = "puppy-reality";
        type = "vless";
        server = ph.reality_server_name;
        port = endpoints.vlessPort;
        uuid = ph.mihomo_vless_uuid;
        network = "tcp";
        flow = "xtls-rprx-vision";
        udp = true;
        tls = true;
        servername = ph.reality_server_name;
        client-fingerprint = "chrome";
        reality-opts = {
          public-key = ph.mihomo_reality_public_key;
          short-id = ph.mihomo_reality_short_id;
        };
      }
      {
        name = "puppy-hy2";
        type = "hysteria2";
        server = ph.reality_server_name;
        port = endpoints.hysteriaPort;
        password = ph.mihomo_hysteria_password;
        sni = ph.reality_server_name;
        up = "50 mbps";
        down = "200 mbps";
      }
    ];

    proxy-groups = [
      {
        name = "proxy";
        type = "select";
        proxies = [
          "puppy-reality"
          "puppy-hy2"
          "DIRECT"
        ];
      }
    ];

    #ru goes direct: yandex/vk/gov hate foreign ips, datacenter ones especially (¬_¬")
    rules = [
      "IP-CIDR,127.0.0.0/8,DIRECT,no-resolve"
      "IP-CIDR,10.0.0.0/8,DIRECT,no-resolve"
      "IP-CIDR,172.16.0.0/12,DIRECT,no-resolve"
      "IP-CIDR,192.168.0.0/16,DIRECT,no-resolve"
      "IP-CIDR,169.254.0.0/16,DIRECT,no-resolve"
      #tailscale, otherwise the whole tailnet would tunnel through puppy which is really bad
      "IP-CIDR,100.64.0.0/10,DIRECT,no-resolve"
      "DOMAIN-SUFFIX,xn--p1ai,DIRECT"     #рф
      "DOMAIN-SUFFIX,ru,DIRECT"
      "DOMAIN-SUFFIX,su,DIRECT"
      "DOMAIN-SUFFIX,xn--p1acf,DIRECT"    #рус
      "DOMAIN-SUFFIX,xn--80asehdb,DIRECT" #онлайн
      "DOMAIN-SUFFIX,xn--c1avg,DIRECT"    #орг
      "DOMAIN-SUFFIX,xn--80aswg,DIRECT"   #сайт
      "DOMAIN-SUFFIX,xn--80adxhks,DIRECT" #москва
      "DOMAIN-SUFFIX,moscow,DIRECT"
      "DOMAIN-SUFFIX,xn--d1acj3b,DIRECT"  #дети (oh fucking no...)
      "GEOSITE,category-gov-ru,DIRECT"
      "GEOSITE,yandex,DIRECT"
      "GEOSITE,vk,DIRECT"
      "GEOSITE,steam,DIRECT"
      "GEOIP,RU,DIRECT"
      "MATCH,proxy"
    ];
  };
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