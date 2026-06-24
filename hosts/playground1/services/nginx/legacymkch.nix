{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.nginx.virtualHosts."lmkch.wejust.rest" = {
    forceSSL = true;
    useACMEHost = "lmkch.wejust.rest";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8888";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_request_buffering off;
      '';
    };
  };

  security.acme.certs."lmkch.wejust.rest" = {
    reloadServices = [ "nginx" ];
  };
}
