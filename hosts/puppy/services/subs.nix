{
  config,
  pkgs,
  abs,
  ...
}:

let
  endpoints = import (abs "lib/mihomo-endpoints.nix");
  ph = config.sops.placeholder;

  clientSettings = import (abs "lib/mihomo-client.nix") { inherit ph endpoints; };

  subDir = "/var/lib/subs";

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
  sops.secrets.sub_id = { };
  sops.secrets.mihomo_reality_public_key = { };

  #the base64 cant happen at eval time: every field in those uris is a sops
  #placeholder that only turns real when the template gets rendered on the box,
  #so sops writes the plaintext list and sub-render encodes it afterwards.
  #mihomo eats yaml straight, so its template is served as-is
  sops.templates."sub-uris" = {
    content = "${vlessUri}\n${hy2Uri}\n";
    restartUnits = [ "sub-render.service" ];
  };

  sops.templates."sub-mihomo.yaml" = {
    content = builtins.toJSON clientSettings;
    owner = "nginx";
    mode = "0440";
  };

  #the secret path segment lives in a rendered snippet so it never reaches the
  #nix store - angie just globs the directory for it
  sops.templates."sub-locations.conf" = {
    content = ''
      location = /${ph.sub_id}/xray {
        default_type text/plain;
        alias ${subDir}/xray;
      }

      location = /${ph.sub_id}/mihomo {
        default_type text/yaml;
        alias ${config.sops.templates."sub-mihomo.yaml".path};
      }
    '';
    owner = "nginx";
    mode = "0440";
    restartUnits = [ "nginx.service" ];
  };

  systemd.services.sub-render = {
    description = "encode the xray sharelink subscription";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StateDirectory = "subs";
      StateDirectoryMode = "0755";
      UMask = "0022";
    };

    script = ''
      set -euo pipefail
      ${pkgs.coreutils}/bin/base64 -w0 \
        ${config.sops.templates."sub-uris".path} > ${subDir}/xray
    '';
  };
}