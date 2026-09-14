{ pkgs, wildcardCert, ... }:

let
  /*
    443 belongs to xray now: reality sits there pretending to be this website,
    and everything it doesnt recognise gets handed straight to angie. so the tls
    side no longer faces the internet at all, it only has to be reachable from
    the reality inbound - which is what makes the disguise honest, a browser on
    port 443 really does end up here and really does get the wildcard cert
  */
  fallback = {
    addr = "127.0.0.1";
    port = 8443;
  };
in
{
  _module.args.angieFallback = fallback;

  services.nginx = {
    enable = true;
    package = pkgs.angie;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    # `_` as the vhost name means server_name _, ie catch-all. keeps the domain
    # out of the config entirely - the wildcard cert covers it anyway
    virtualHosts."_" = {
      default = true;
      forceSSL = true;
      http2 = true;

      # 80 stays public so the box still behaves like a plain website from the
      # outside; forceSSL turns it into the usual redirect to 443, ie to xray
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          inherit (fallback) addr port;
          ssl = true;
        }
      ];

      sslCertificate = wildcardCert.fullchain;
      sslCertificateKey = wildcardCert.key;

      # everything that isnt a subscription file lands here - subs.nix owns
      # `/` and falls back to this
      locations."@woof" = {
        return = "200 'woof woof :3\\n'";
        extraConfig = ''
          default_type text/plain;
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
