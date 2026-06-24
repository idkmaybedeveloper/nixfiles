{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.nginx.virtualHosts."uran.wejust.rest" = {
    forceSSL = true;
    useACMEHost = "uran.wejust.rest";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8994";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."uran.wejust.rest" = {
    reloadServices = [ "nginx" ];
  };
}
