{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../base
  ];

  http.base = {
    enable = true;

    sites."hydra.wejust.rest" = {
      host = "hydra.wejust.rest";

      proxy = {
        url = "http://127.0.0.1:9055";
        websockets = true;
        passHostHeader = true;
        # HACK:NOTE(kroot):REF:https://nginx.org/en/docs/http/ngx_http_sub_module.html
        # hydra generates http:// links ignoring X-Forwarded-Proto so
        # rewrite at nginx level. Accept-Encoding "" req for sub_filter
        # HACK:NOTE(kroot): rewrite Origin/Referer to http so Hydras' csrf check passes,
        extraConfig = ''
          proxy_set_header X-Request-Base https://hydra.wejust.rest; #NOTE(kroot): https://hydra.nixos.org/build/328901960/download/1/hydra/configuration.html
        '';
      };
      extraLocations."/static/" = {
        alias = "${pkgs.hydra}/libexec/hydra/root/static/";
      };
    };
  };

  #environment.etc."hydra-http/index.html".text = "I_AM_ALIVE";

  #systemd.services.hello-http = {
  #  description = "soon on 9055";
  #  wantedBy = [ "multi-user.target" ];
  #  after = [ "network.target" ];
  #  serviceConfig = {
  #    Type = "simple";
  #    WorkingDirectory = "/etc/hello-http";
  #    ExecStart = "${pkgs.python3}/bin/python -m http.server 9055 --bind 127.0.0.1";
  #    Restart = "always";
  #    RestartSec = 2;
  #  };
  #};

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.wejust.rest/";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    port = 9055;
    #TODO(kroot): mb better setup pgsql??
    #dbi = "dbi:Pg:dbname=hydra;user=hydra;host=192.168.1.65:9432";
    extraConfig = ''
      using_frontend_proxy 1
      store_uri = s3://nixos?compression=zstd&parallel-compression=true&write-nar-listing=1&secret-key=/etc/hydra/cache-priv-key.pem&endpoint=https://shit.cuddles.rs&region=us-east-1
      binary_cache_public_uri = https://shit.cuddles.rs/nixos
    ''; # NOTE(kroot):ref: https://metacpan.org/pod/Catalyst#PROXY-SUPPORT
  };

  systemd.services.hydra-queue-runner.serviceConfig.EnvironmentFile = "/etc/hydra/s3-env";
}
