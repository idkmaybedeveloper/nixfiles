{
  config,
  lib,
  pkgs,
  abs,
  wildcardCert,
  ...
}:

let
  endpoints = import (abs "lib/proxy-endpoints.nix");

  # systemd drops LoadCredential= here, which is how the cert reaches a
  # DynamicUser service that owns nothing on disk
  creds = "/run/credentials/xray.service";

  # 80/443 belong to angie and stay a plain boring website...
  inherit (endpoints) vlessPort hysteriaPort;

  # ref: https://xtls.github.io/config/
  # ph is config.sops.placeholder on the box and a pile of stand-ins in the
  # build-time check below, and the cert paths move with it, so both configs
  # keep the exact same shape
  mkSettings =
    { ph, cert, key }:
    {
      log.loglevel = "warning";

      inbounds = [
        {
          tag = "vless-reality";
          listen = "0.0.0.0";
          port = vlessPort;
          protocol = "vless";
          settings = {
            clients = [
              {
                id = ph.xray_vless_uuid;
                flow = "xtls-rprx-vision";
                email = "lain";
              }
            ];
            decryption = "none";
          };
          streamSettings = {
            network = "raw";
            security = "reality";
            realitySettings = {
              target = "127.0.0.1:443";
              serverNames = [ ph.reality_server_name ];
              privateKey = ph.xray_reality_private_key;
              shortIds = [ ph.xray_reality_short_id ];
            };
          };
        }
        {
          tag = "hysteria2";
          listen = "0.0.0.0";
          port = hysteriaPort;
          protocol = "hysteria";
          settings = {
            version = 2;
            clients = [
              {
                auth = ph.xray_hysteria_password;
                email = "lain";
              }
            ];
          };
          streamSettings = {
            network = "hysteria";
            security = "tls";
            tlsSettings = {
              alpn = [ "h3" ];
              certificates = [
                {
                  certificateFile = cert;
                  keyFile = key;
                }
              ];
            };
            hysteriaSettings = {
              version = 2;
              masquerade = {
                type = "proxy";
                url = "http://127.0.0.1:80";
              };
            };
            # hysteria2's rate knobs moved out of hysteriaSettings into the
            # finalmask block upstream. congestion "brutal" still degrades to
            # bbr on its own when a client doesnt announce its own downlink
            finalmask.quicParams = {
              congestion = "brutal";
              brutalUp = "200 mbps";
              brutalDown = "200 mbps";
            };
          };
        }
      ];

      outbounds = [
        {
          tag = "direct";
          protocol = "freedom";
        }
        {
          tag = "block";
          protocol = "blackhole";
        }
      ];

      # the reality fallback to angie and the hysteria2 masquerade are dialed
      # inside their transports, not through routing, so unlike the mihomo
      # ruleset this needs no carve-out for 127.0.0.1:443 / :80
      routing.rules = [
        {
          type = "field";
          outboundTag = "block";
          ip = [
            "127.0.0.0/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "169.254.0.0/16"
            "::1/128"
            "fc00::/7"
            "fe80::/10"
          ];
        }
      ];
    };

  checkConfig = pkgs.writeText "xray-check.json" (
    builtins.toJSON (mkSettings {
      cert = "@cert@";
      key = "@key@";
      ph = {
        xray_vless_uuid = "00000000-0000-0000-0000-000000000000";
        xray_reality_private_key = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"; # 32 zero bytes
        xray_reality_short_id = "0123456789abcdef";
        xray_hysteria_password = "hunter2";
        reality_server_name = "example.com";
      };
    })
  );

  configCheck =
    pkgs.runCommand "xray-config-check" { nativeBuildInputs = [ pkgs.openssl ]; }
      ''
        openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
          -subj "/CN=localhost" -keyout key.pem -out cert.pem

        substitute ${checkConfig} config.json \
          --subst-var-by cert "$PWD/cert.pem" \
          --subst-var-by key "$PWD/key.pem"

        ${pkgs.xray}/bin/xray -test -config config.json
        touch $out
      '';
in
{
  sops.secrets.xray_vless_uuid = { };
  sops.secrets.xray_reality_private_key = { };
  sops.secrets.xray_reality_short_id = { };
  sops.secrets.xray_hysteria_password = { };
  sops.secrets.reality_server_name = { };

  sops.templates."xray.json" = {
    content = builtins.toJSON (mkSettings {
      ph = config.sops.placeholder;
      cert = "${creds}/cert.pem";
      key = "${creds}/key.pem";
    });
    # otherwise a config change just sits there until the next reboot
    restartUnits = [ "xray.service" ];
  };

  services.xray = {
    enable = true;
    settingsFile = config.sops.templates."xray.json".path;
  };

  system.extraDependencies = [ configCheck ];

  systemd.services.xray = {
    # the upstream unit has neither, and xray parses (ie opens) the hysteria2
    # certificate on startup, so it must not race the cert units
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig.LoadCredential = lib.mkForce [
      "config.json:${config.sops.templates."xray.json".path}"
      "cert.pem:${wildcardCert.fullchain}"
      "key.pem:${wildcardCert.key}"
    ];
  };

  # for `xray uuid` / `xray x25519`
  environment.systemPackages = [ pkgs.xray ];

  #nix-topology has no extractor for xray, so the listeners are declared here
  topology.self.services.xray = {
    name = "xray";
    info = "vless-reality + hysteria2";
    details.listen.text = ''
      tcp 0.0.0.0:${toString vlessPort} (vless reality)
      udp 0.0.0.0:${toString hysteriaPort} (hysteria2)
    '';
  };

  networking.firewall.allowedTCPPorts = [ vlessPort ];
  networking.firewall.allowedUDPPorts = [ hysteriaPort ];
}
