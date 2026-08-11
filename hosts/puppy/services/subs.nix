{
  config,
  lib,
  pkgs,
  abs,
  ...
}:

let
  endpoints = import (abs "lib/mihomo-endpoints.nix");
  ph = config.sops.placeholder;

  clientSettings = import (abs "lib/mihomo-client.nix") { inherit ph endpoints; };

  subsDir = "/var/lib/subs";

  #write these as plain text, base64.nix encodes them the way clients expect
  b64 = import (abs "lib/base64.nix") { inherit lib; };

  profileTitle = "cuddles.rs vpn infra";
  announce = "meow meow mrrp nya nya awaw nyahmm :3";

  inherit (endpoints) vlessPort hysteriaPort;

  vlessUri =
    "vless://${ph.mihomo_vless_uuid}@${ph.reality_server_name}:${toString vlessPort}"
    + "?encryption=none&security=reality&type=tcp&flow=xtls-rprx-vision"
    + "&sni=${ph.reality_server_name}&fp=chrome"
    + "&pbk=${ph.mihomo_reality_public_key}&sid=${ph.mihomo_reality_short_id}"
    + "#puppy-reality";

  hy2Uri =
    "hy2://${ph.mihomo_hysteria_password}@${ph.reality_server_name}:${toString hysteriaPort}"
    + "?sni=${ph.reality_server_name}&alpn=h3"
    + "#puppy-hy2";
in
{
  sops.secrets.sub_id.restartUnits = [ "sub-render.service" ];
  sops.secrets.mihomo_reality_public_key = { };

  sops.templates."sub-uris" = {
    content = "${vlessUri}\n${hy2Uri}\n";
    restartUnits = [ "sub-render.service" ];
  };

  sops.templates."sub-mihomo.yaml" = {
    content = builtins.toJSON clientSettings;
    restartUnits = [ "sub-render.service" ];
  };

  # lol none of these headers are specified anywhere: its convention grown out of
  # shadowrocket and clash, and remnawave still carries a "remove after XTLS
  # Standards published" todo over its expire field.
  # #justfuckstupidvpnclients
  services.nginx.virtualHosts."_".locations."/" = {
    root = subsDir;
    tryFiles = "$uri @woof";

    extraConfig = ''
      default_type text/plain;
      add_header Content-Disposition 'attachment; filename=puppy';
      add_header Subscription-Userinfo 'upload=0; download=0; total=0; expire=0';
      add_header Profile-Title 'base64:${b64 profileTitle}';
      add_header Announce 'base64:${b64 announce}'; 
      add_header Profile-Update-Interval '24';
      add_header Support-Url 'https://iamtsunde.re';
      add_header Profile-Web-Page-Url 'https://iamtsunde.re';
      add_header X-Hwid-Not-Supported 'true';
    '';
  };

  systemd.services.sub-render = {
    description = "publish the subscriptions under the secret path";
    wantedBy = [ "multi-user.target" ];

    path = [
      pkgs.coreutils
      pkgs.findutils
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "subs";
      StateDirectoryMode = "0755";
      UMask = "0022";
    };

    script = ''
      set -euo pipefail

      id=$(cat ${config.sops.secrets.sub_id.path})
      install -d -m 0755 ${subsDir}/"$id"

      #the base64 cant happen at eval time: every field in those uris is a sops
      #placeholder that only turns real once the template is rendered on the box
      base64 -w0 ${config.sops.templates."sub-uris".path} > ${subsDir}/"$id"/xray
      chmod 0444 ${subsDir}/"$id"/xray

      install -m 0444 ${config.sops.templates."sub-mihomo.yaml".path} \
        ${subsDir}/"$id"/mihomo

      #subsDir is a document root now, so anything sitting in it is reachable.
      #a rotated sub_id would leave the old path live forever, and the old
      #layout left a bare xray file right at the root - both go away here
      find ${subsDir} -mindepth 1 -maxdepth 1 ! -name "$id" -exec rm -rf {} +
    '';
  };
}
