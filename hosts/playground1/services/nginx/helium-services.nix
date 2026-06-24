{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.nginx = {
    upstreams."helium-exts" = {
      servers = {
        "127.0.0.1:8001" = { };
        "127.0.0.1:8002" = {
          backup = true;
        };
      };
    };
  };

  services.nginx.virtualHosts."helium.wejust.rest" = {
    forceSSL = true;
    useACMEHost = "helium.wejust.rest";
    locations."/" = {
      return = "302 https://helium.computer";
    };
    locations."/robots.txt" = {
      extraConfig = ''
        add_header Content-Type text/plain always;
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options DENY always;
        add_header Referrer-Policy no-referrer-when-downgrade always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
        return 200 "User-agent: *\nDisallow: /\n";
      '';
    };
    locations."/bangs.json" = {
      root = "/dev/shm/bangs";
      extraConfig = ''
        add_header Cache-Control "public, max-age=86400, stale-if-error=604800" always;
        add_header Access-Control-Allow-Origin * always;
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options DENY always;
        add_header Referrer-Policy no-referrer-when-downgrade always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
      '';
    };
    locations."/updates/mac" = {
      proxyPass = "https://updates.helium.computer/mac";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host updates.helium.computer;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_ssl_server_name on;
        proxy_ssl_verify on;
        proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
      '';
    };
    locations."/dict" = {
      root = "/dev/shm/dictionaries";
      extraConfig = ''
        gzip_static always;
        autoindex on;
        sub_filter ".gz" "";
        sub_filter_once off;
      '';
    };
    locations."/ext" = {
      proxyPass = "http://helium-exts/";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
    locations."/ubo/" = {
      proxyPass = "http://127.0.0.1:8000/";
      extraConfig = ''
        proxy_pass_request_body off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };

  security.acme.certs."helium.wejust.rest" = {
    reloadServices = [ "nginx" ];
  };
}
