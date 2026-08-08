{ pkgs, wildcardCert, ... }:

{
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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
