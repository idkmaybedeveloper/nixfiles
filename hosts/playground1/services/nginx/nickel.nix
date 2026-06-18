{ config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts."nickel.wejust.rest" = {
    forceSSL = true;
    useACMEHost = "nickel.wejust.rest";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8993";
      proxyWebsockets = true;
    };
  };

  security.acme.certs."nickel.wejust.rest" = {
    reloadServices = [ "nginx" ];
  };
}


