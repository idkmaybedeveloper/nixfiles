{
  pkgs,
  wildcardCert,
  subsDir,
  ...
}:

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

      #the subscriptions are plain files under a directory named after the
      #secret, so nothing in here knows the id and nothing has to be rendered
      #at parse time - anything that isnt a real file falls through to the woof
      locations."/" = {
        root = subsDir;
        tryFiles = "$uri @woof";
        extraConfig = ''
          default_type text/plain;
        '';
      };

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
