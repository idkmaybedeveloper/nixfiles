{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.nginx = {
    enable = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    enableReload = true;
    commonHttpConfig = ''
      proxy_headers_hash_max_size 1024;
      proxy_headers_hash_bucket_size 128;
    '';
    virtualHosts."knot-fl1.wejust.rest" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5555";
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
      locations."/events" = {
        proxyPass = "http://127.0.0.1:5555";
        extraConfig = ''
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header Host $host;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
    };
  };

  security.acme.certs."knot-fl1.wejust.rest" = {
    reloadServices = [ "nginx" ];
  };
}
