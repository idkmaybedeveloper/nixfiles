{ config, lib, pkgs, ... }:

{
  services.nginx = {
    enable = true;
    virtualHosts."knot-fl2.wejust.rest" = {
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

  security.acme = {
    acceptTerms = true;
    defaults.email = "lain@lainmail.xyz";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
