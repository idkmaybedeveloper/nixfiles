{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    concatMapStrings
    optionalAttrs
    optionalString
    types
    mapAttrs'
    ;

  cfg = config.http.base;
in
{
  options.http.base = {
    enable = mkEnableOption "simple angie http setup";

    listenPort = mkOption {
      type = types.int;
      default = 80;
      description = "Port for all http virtual hosts.";
    };

    clientMaxBodySize = mkOption {
      type = types.str;
      default = "10m";
      description = "client_max_body_size for angie.";
    };

    realIpHeader = mkOption {
      type = types.str;
      default = "X-Forwarded-For";
      description = "Header to use for real_ip_header.";
    };

    realIpTrustedRanges = mkOption {
      type = types.listOf types.str;
      default = [
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "10.100.5.0/8"
      ];
      description = "CIDR ranges from which X-Forwarded-For is trusted.";
    };

    sites = mkOption {
      type = types.attrsOf (
        types.submodule (
          { name, ... }: {
            options = {
              host = mkOption {
                type = types.str;
                default = name;
                description = "server_name for this site.";
              };

              root = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Static root, if serving files.";
              };

              proxy = mkOption {
                type = types.nullOr (
                  types.submodule {
                    options = {
                      url = mkOption {
                        type = types.str;
                        description = "proxy_pass target, like http://127.0.0.1:9000.";
                      };

                      websockets = mkOption {
                        type = types.bool;
                        default = false;
                        description = "Enable proxy_websockets.";
                      };

                      passHostHeader = mkOption {
                        type = types.bool;
                        default = true;
                        description = "Set Host and X-Forwarded-* headers.";
                      };

                      extraConfig = mkOption {
                        type = types.lines;
                        default = "";
                        description = "Extra nginx config for the proxy location.";
                      };
                    };
                  }
                );
                default = null;
                description = "Proxy configuration for this site.";
              };

              extraLocations = mkOption {
                type = types.attrsOf (types.attrsOf types.anything);
                default = { };
                description = "Extra nginx locations merged into virtualHost.locations.";
              };
            };
          }
        )
      );
      default = { };
      description = "All simple http sites for angie.";
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      package = pkgs.angie;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      enableReload = true;
      clientMaxBodySize = cfg.clientMaxBodySize;
      serverTokens = false;

      commonHttpConfig = ''
        add_header X-Content-Type-Options nosniff always;
        add_header Referrer-Policy no-referrer-when-downgrade always;
        add_header X-XSS-Protection "1; mode=block" always;
        real_ip_header ${cfg.realIpHeader};
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Port 443;
      ''
      + concatMapStrings (cidr: "        set_real_ip_from ${cidr};\n") cfg.realIpTrustedRanges
      + "";

      virtualHosts = mapAttrs' (
        name: site:
        let
          base = {
            serverName = site.host;
            listen = [
              {
                addr = "0.0.0.0";
                port = cfg.listenPort;
              }
            ];
          };

          rootCfg = optionalAttrs (site.root != null) {
            root = site.root;
          };

          proxyLoc =
            if site.proxy == null then
              { }
            else
              {
                locations."/" = {
                  proxyPass = site.proxy.url;
                  proxyWebsockets = site.proxy.websockets;
                  extraConfig =
                    (optionalString site.proxy.passHostHeader ''
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto https;
                    '')
                    + site.proxy.extraConfig;
                };
              };
        in
        {
          name = site.host;
          value =
            let
              baseLocations = proxyLoc.locations or { };
            in
            base
            // rootCfg
            // {
              locations = baseLocations // site.extraLocations;
            };
        }
      ) cfg.sites;
    };

    networking.firewall.allowedTCPPorts = [ cfg.listenPort ];

    system.activationScripts.nginxLogs.text = ''
      mkdir -p /var/log/nginx
      chown nginx:nginx /var/log/nginx
      chmod 0750 /var/log/nginx
      touch /var/log/nginx/access.log /var/log/nginx/error.log
      chown nginx:nginx /var/log/nginx/access.log /var/log/nginx/error.log
      chmod 0640 /var/log/nginx/access.log /var/log/nginx/error.log
    '';
  };
}
