{ config, lib, pkgs, ... }:

{
  services.nginx.virtualHosts."nx.cuddles.rs" = {
    forceSSL = true;
    useACMEHost = "nx.cuddles.rs";
    extraConfig = "client_max_body_size 512m;";
    locations."/" = {
      proxyPass = "http://127.0.0.1:3030";
      proxyWebsockets = true;
    };
  };
}