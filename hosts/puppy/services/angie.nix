{
  config,
  pkgs,
  wildcardCert,
  ...
}:

let
  #a glob, not a plain include: the file only exists once sops has rendered it,
  #and nginx -t at build time would choke on a missing literal path
  subLocations = "${
    builtins.dirOf config.sops.templates."sub-locations.conf".path
  }/sub-locations*.conf";
in
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

      extraConfig = ''
        include ${subLocations};
      '';

      locations."/" = {
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