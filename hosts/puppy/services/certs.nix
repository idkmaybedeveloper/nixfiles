{ config, pkgs, ... }:

let
  certDir = "/var/lib/wildcard-cert";
  fullchain = "${certDir}/fullchain.pem";
  key = "${certDir}/key.pem";

  domainFile = config.sops.secrets.acme_domain.path;
  tokenFile = config.sops.secrets.cloudflare_dns_token.path;
in
{
  sops.secrets.acme_domain = { };
  sops.secrets.cloudflare_dns_token = { };
  systemd.services.wildcard-cert = {
    description = "issue/renew the wildcard certificate";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    # so a fresh box gets a real cert on its own, without waiting for the timer
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.lego
      pkgs.systemd
      pkgs.diffutils
    ];

    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "lego wildcard-cert";
      StateDirectoryMode = "0750";
      UMask = "0027";

      # systemd chowns StateDirectory to User:Group on every start, so this is
      # the only way the group survives - a chgrp in the script gets undone
      Group = "nginx";
    };

    script = ''
      set -euo pipefail

      domain=$(cat ${domainFile})
      export CLOUDFLARE_DNS_API_TOKEN=$(cat ${tokenFile})

      lego_args=(
        --accept-tos
        --email lain@iwakura.page
        --dns cloudflare
        --path /var/lib/lego
        --domains "$domain"
        --domains "*.$domain"
      )

      if [ -f "/var/lib/lego/certificates/$domain.crt" ]; then
        lego "''${lego_args[@]}" renew --days 30
      else
        lego "''${lego_args[@]}" run
      fi

      src="/var/lib/lego/certificates/$domain"

      if ! cmp -s "$src.crt" ${fullchain}; then
        install -m 0640 -g nginx "$src.crt" ${fullchain}
        install -m 0640 -g nginx "$src.key" ${key}

        systemctl reload-or-restart nginx.service || true
        systemctl try-restart mihomo.service || true
      fi
    '';
  };

  #plain systemd units, so nothing upstream would pick them up for the topology
  topology.self.services.wildcard-cert = {
    name = "wildcard-cert";
    info = "lego, cloudflare dns-01, daily timer";
  };

  systemd.timers.wildcard-cert = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "6h";
      Persistent = true;
    };
  };

  systemd.services.wildcard-cert-bootstrap = {
    description = "self-signed placeholder until lego gets its first cert";
    wantedBy = [ "multi-user.target" ];
    before = [
      "nginx.service"
      "mihomo.service"
    ];
    requiredBy = [
      "nginx.service"
      "mihomo.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "wildcard-cert";
      StateDirectoryMode = "0750";
      UMask = "0027";
      Group = "nginx";
    };

    script = ''
      set -euo pipefail
      [ -f ${fullchain} ] && exit 0

      ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 1 \
        -subj "/CN=localhost" -keyout ${key} -out ${fullchain}

      chmod 0640 ${fullchain} ${key}
    '';
  };

  _module.args.wildcardCert = {
    inherit fullchain key;
  };
}
