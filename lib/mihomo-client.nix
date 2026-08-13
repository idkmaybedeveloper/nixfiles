#the client side of puppy, shared between the darwin daemon and the subscription
#endpoint puppy serves - so a rule tweak lands in both at once
#`ph` is config.sops.placeholder of whichever host is rendering this, so every
#secret stays a placeholder until sops writes the file out on the box itself
#`offlineGeodata` is for hosts that get their geoip.dat/geosite.dat handed to
#them from the nix store: mihomo otherwise fetches them from github on the first
#run, which behind the tspu just dies with EOF and takes the whole start with it
{
  ph,
  endpoints,
  tun ? false,
  offlineGeodata ? false,
}:

let
  base = {
    mixed-port = 7890;
    allow-lan = false;
    mode = "rule";
    log-level = "info";
    ipv6 = false;

    geodata-mode = true;
    geo-auto-update = !offlineGeodata;
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
      "IP-CIDR,100.64.0.0/10,DIRECT,no-resolve"
      "DOMAIN-SUFFIX,ts.net,DIRECT"
      "DOMAIN,shit.cuddles.rs,DIRECT"
      "DOMAIN-SUFFIX,xn--p1ai,DIRECT" # рф
      "DOMAIN-SUFFIX,ru,DIRECT"
      "DOMAIN-SUFFIX,su,DIRECT"
      "DOMAIN-SUFFIX,xn--p1acf,DIRECT" # рус
      "DOMAIN-SUFFIX,xn--80asehdb,DIRECT" # онлайн
      "DOMAIN-SUFFIX,xn--c1avg,DIRECT" # орг
      "DOMAIN-SUFFIX,xn--80aswg,DIRECT" # сайт
      "DOMAIN-SUFFIX,xn--80adxhks,DIRECT" # москва
      "DOMAIN-SUFFIX,moscow,DIRECT"
      "DOMAIN-SUFFIX,xn--d1acj3b,DIRECT" # дети (oh fucking no...)
      "GEOSITE,category-gov-ru,DIRECT"
      "GEOSITE,yandex,DIRECT"
      "GEOSITE,vk,DIRECT"
      "GEOSITE,steam,DIRECT"
      "GEOIP,RU,DIRECT"
      "MATCH,proxy"
    ];
  };

  #transparent mode. `system` stack is the kernel one - fastest of the three and
  #the only one that doesnt need gvisor's userspace tcp stack in the hot path.
  #dns-hijack catches queries aimed at whatever nameserver dhcp handed out, so
  #resolv.conf can stay untouched (mihomos unit runs under ProtectSystem=strict
  #and couldnt rewrite it anyway)
  tunSettings = {
    tun = {
      enable = true;
      stack = "system";
      device = "mihomo0";
      auto-route = true;
      auto-detect-interface = true;
      #keep the tailnet out of the tun entirely: shit.cuddles.rs resolves to a
      #100.64/10 address, so without this the packets enter mihomo0, come back
      #out as a DIRECT dial bound to the default (physical) interface and never
      #reach tailscale0 at all
      route-exclude-address = [ "100.64.0.0/10" ];
      dns-hijack = [
        "any:53"
        "tcp://any:53"
      ];
    };

    dns = {
      enable = true;
      ipv6 = false;
      listen = "127.0.0.1:1053";
      enhanced-mode = "fake-ip";
      #the usual 198.18.0.1/16 default collides with real hops on the way to our
      #own boxes (a traceroute from puppy walks through live 198.18.70.x), and a
      #fake range that overlaps a real network eats addresses that exist
      fake-ip-range = "241.0.0.1/8";

      #a fake ip for these would break them: magicdns names must resolve to the
      #real 100.64/10 address, and lan/mdns names never leave the link anyway
      fake-ip-filter = [
        "+.ts.net"
        #handing nix a 241.x fake-ip for the cache would drag the download back
        #into the tun even though the rule says DIRECT
        "shit.cuddles.rs"
        "+.lan"
        "+.local"
        "+.home.arpa"
        "time.*.com"
        "+.pool.ntp.org"
      ];

      default-nameserver = [
        "1.1.1.1"
        "9.9.9.9"
      ];
      nameserver = [
        "https://cloudflare-dns.com/dns-query"
        "https://dns.quad9.net/dns-query"
      ];

      #the ru side of the ruleset goes direct, so resolve it directly too -
      #foreign resolvers hand out cdn ips that ru sites then refuse to serve
      nameserver-policy = {
        "+.ts.net" = "100.100.100.100";
        #plain udp on purpose: the DoH resolvers above are themselves reached
        #through the ruleset, so resolving the cache would ride the tunnel it is
        #supposed to stay out of
        "shit.cuddles.rs" = [
          "1.1.1.1"
          "9.9.9.9"
        ];
        "geosite:category-gov-ru,yandex,vk" = [
          "77.88.8.8"
          "77.88.8.1"
        ];
        "+.ru,+.su,+.рф" = [
          "77.88.8.8"
          "77.88.8.1"
        ];
      };
    };
  };
in
if tun then base // tunSettings else base
