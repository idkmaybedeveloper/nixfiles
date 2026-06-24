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
    clientMaxBodySize = "10m";
    commonHttpConfig = ''
      add_header X-Content-Type-Options nosniff always;
      add_header X-Frame-Options DENY always;
      add_header Referrer-Policy no-referrer-when-downgrade always;
      add_header X-XSS-Protection "1; mode=block" always;
      add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    '';
    virtualHosts."icq.wejust.rest" = {
      forceSSL = true;
      useACMEHost = "icq.wejust.rest";
      locations."/" = {
        return = "301 https://github.com/mk6i/open-oscar-server";
      };
    };
  };

  system.activationScripts.nginxLogs.text = ''
    mkdir -p /var/log/nginx
    chown nginx:nginx /var/log/nginx
    chmod 0750 /var/log/nginx
    touch /var/log/nginx/access.log /var/log/nginx/error.log
    chown nginx:nginx /var/log/nginx/access.log /var/log/nginx/error.log
    chmod 0640 /var/log/nginx/access.log /var/log/nginx/error.log
  '';

  security.acme.certs."icq.wejust.rest" = {
    reloadServices = [ "nginx" ];
  };

  networking.firewall.allowedTCPPorts = [
    443
    80
  ];
}
