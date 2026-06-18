{ config, ... }:

{
  # exit-node tailscale shared by the hostkey playgrounds; the advertised
  # hostname follows networking.hostName so the module stays host-agnostic
  services.tailscale = {
    enable = true;
    # NOTE(kroot): https://discourse.nixos.org/t/tailscale-exit-node-not-working-on-nixos/39897
    useRoutingFeatures = "both";
    extraSetFlags = [
      "--advertise-exit-node"
      "--hostname=${config.networking.hostName}"
    ];
    extraDaemonFlags = [ "--no-logs-no-support" ];
  };
}