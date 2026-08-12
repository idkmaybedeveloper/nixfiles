{
  config,
  pkgs,
  abs,
  ...
}:

let
  endpoints = import (abs "lib/mihomo-endpoints.nix");

  # same secrets the darwin daemon uses; puppy.yaml is encrypted for alphys too
  # now (see .sops.yaml), so the box unwraps them with its own key
  puppySecret = name: {
    inherit name;
    value = {
      sopsFile = abs "secrets/puppy.yaml";
      restartUnits = [ "mihomo.service" ];
    };
  };

  ph = config.sops.placeholder;

  settings = import (abs "lib/mihomo-client.nix") {
    inherit ph endpoints;
    tun = true;
  };
in
{
  sops.secrets = builtins.listToAttrs (
    map puppySecret [
      "reality_server_name"
      "mihomo_vless_uuid"
      "mihomo_reality_public_key"
      "mihomo_reality_short_id"
      "mihomo_hysteria_password"
    ]
  );

  sops.templates."mihomo-client.yaml" = {
    content = builtins.toJSON settings;
    restartUnits = [ "mihomo.service" ];
  };

  services.mihomo = {
    enable = true;
    # CAP_NET_ADMIN for the tun device; the tun block itself lives in the config
    tunMode = true;
    configFile = config.sops.templates."mihomo-client.yaml".path;
  };

  # the tun interface carries already-decided traffic, and the default zone
  # would drop the replies coming back in on it
  networking.firewall.trustedInterfaces = [ "mihomo0" ];

  # sops decrypts with /home/lain/.ssh/agenix_key (partials.sops-base), but the
  # secrets go in from an activation script in stage-2, before systemd mounts
  # /home - so on a cold boot nothing gets rendered and mihomo's LoadCredential
  # dies with "no such file"
  fileSystems."/home".neededForBoot = true;

  # NOTE(lain): tailscale runs its own tun next to this one. 100.64/10 and
  # *.ts.net are DIRECT in the ruleset and excluded from fake-ip, so the tailnet
  # keeps working, but if a magicdns name ever starts resolving to 198.18.x.y
  # that is the pair fighting - check fake-ip-filter first.
}
