{
  config,
  lib,
  pkgs,
  ...
}:

let
  heliumPkg = pkgs.stdenv.mkDerivation {
    name = "helium-services";
    src = pkgs.fetchFromGitHub {
      owner = "imputnet";
      repo = "helium-services";
      rev = "d40a6b252605a1c8868fd6d30b2dda9e4c6cc4f5";
      sha256 = "sha256-MR10Yvgx6gWbpOYbhOwuOHMISWR41faVfzuE0XNlJBU=";
    };

    nativeBuildInputs = with pkgs; [ deno ];

    buildPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib/helium-services

      cp svc/nginx/refresh-bangs.sh $out/bin/helium-refresh-bangs
      cp svc/nginx/refresh-dicts.sh $out/bin/helium-refresh-dicts
      cp svc/nginx/refresh-cert.sh $out/bin/helium-refresh-cert

      chmod +x $out/bin/helium-refresh-bangs
      chmod +x $out/bin/helium-refresh-dicts
      chmod +x $out/bin/helium-refresh-cert

      cp -r svc/ubo $out/lib/helium-services/ubo
      cp -r svc/extension-proxy $out/lib/helium-services/extension-proxy
      cp -r svc/minipush $out/lib/helium-services/minipush

      rm -f $out/lib/helium-services/ubo/deno.lock
      rm -f $out/lib/helium-services/extension-proxy/deno.lock
      rm -f $out/lib/helium-services/minipush/deno.lock
    '';

    installPhase = ''
      :
    '';
  };

  loadEnv = pkgs.writeShellScript "load-helium-env" ''
    if [ -f /etc/somesecrets/heliumenv ]; then
      set -a
      . /etc/somesecrets/heliumenv
      set +a
    fi
    exec "$@"
  '';

in
{
  environment.systemPackages = [ heliumPkg ];

  systemd.services.helium-ubo = {
    description = "Helium uBO Proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 3;
      WorkingDirectory = "${heliumPkg}/lib/helium-services/ubo";
      StandardOutput = "journal";
      StandardError = "journal";
      Environment = [ "DENO_DIR=/var/lib/helium-ubo/.deno" ];
      StateDirectory = "helium-ubo";
      ExecStart = ''
        ${loadEnv} ${pkgs.deno}/bin/deno serve \
          --allow-env=UBO_PROXY_BASE_URL,UBO_USE_ORIGINAL_UBLOCK_ASSETS,UBO_ASSETS_JSON_URL,UBO_ASSETS_JSON_SHA256 \
          --allow-net \
          --port=8000 \
          --no-lock \
          main.ts
      '';
    };
  };

  systemd.services.helium-ext-proxy = {
    description = "Helium Extension Proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 3;
      WorkingDirectory = "${heliumPkg}/lib/helium-services/extension-proxy";
      StandardOutput = "journal";
      StandardError = "journal";
      Environment = [ "DENO_DIR=/var/lib/helium-ext-proxy/.deno" ];
      StateDirectory = "helium-ext-proxy";
      ExecStart = ''
        ${loadEnv} ${pkgs.deno}/bin/deno serve \
          --allow-env=HMAC_SECRET,PROXY_BASE_URL \
          --allow-net \
          --parallel \
          --port=8001 \
          --no-lock \
          main.ts
      '';
    };
  };

  systemd.services.helium-ext-proxy-2 = {
    description = "Helium Extension Proxy Backup";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 3;
      WorkingDirectory = "${heliumPkg}/lib/helium-services/extension-proxy";
      StandardOutput = "journal";
      StandardError = "journal";
      Environment = [ "DENO_DIR=/var/lib/helium-ext-proxy-2/.deno" ];
      StateDirectory = "helium-ext-proxy-2";
      ExecStart = ''
        ${loadEnv} ${pkgs.deno}/bin/deno serve \
          --allow-env=HMAC_SECRET,PROXY_BASE_URL \
          --allow-net \
          --parallel \
          --port=8002 \
          --no-lock \
          main.ts
      '';
    };
  };

  systemd.services.helium-minipush = {
    description = "Helium minipush (web push server)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 3;
      WorkingDirectory = "${heliumPkg}/lib/helium-services/minipush";
      StandardOutput = "journal";
      StandardError = "journal";
      Environment = [
        "DENO_DIR=/var/lib/helium-minipush/.deno"
        "MINIPUSH_BIND_HOSTNAME=127.0.0.1"
        "MINIPUSH_PORT=10001"
      ];
      StateDirectory = "helium-minipush";
      ExecStart = ''
        ${loadEnv} ${pkgs.deno}/bin/deno run \
          --allow-env=MINIPUSH_BIND_HOSTNAME,MINIPUSH_PORT,MINIPUSH_BASE_URL,MINIPUSH_HMAC_SECRET,MINIPUSH_ENDPOINT_SECRET,MINIPUSH_MAX_TTL_SECONDS,MINIPUSH_MAX_QUEUED_PER_CHANNEL,MINIPUSH_RATE_LIMIT_WINDOW,MINIPUSH_RATE_LIMIT,MINIPUSH_REQUIRE_VAPID \
          --allow-net \
          --no-lock \
          main.ts
      '';
    };
  };

  systemd.services.helium-refresh-bangs = {
    description = "Helium Refresh Bangs";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [
      curl
      gzip
      diffutils
      gnutar
    ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      ExecStart = "${heliumPkg}/bin/helium-refresh-bangs";
    };
  };

  systemd.services.helium-refresh-dicts = {
    description = "Helium Refresh Dictionaries";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = with pkgs; [
      curl
      gzip
      gnutar
      findutils
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${heliumPkg}/bin/helium-refresh-dicts";
    };
  };

  systemd.timers.helium-refresh-dicts = {
    description = "Helium Refresh Dictionaries (daily)";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /dev/shm/bangs 0755 root root -"
    "d /dev/shm/dictionaries 0755 root root -"
  ];

}