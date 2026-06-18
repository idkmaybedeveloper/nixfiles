{ config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts."co.wejust.rest" = {
    forceSSL = true;
    useACMEHost = "co.wejust.rest";
    locations."/" = {
      proxyPass = "http://127.0.0.1:9000";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."co.wejust.rest" = {
    reloadServices = [ "nginx" ];
  };
}


