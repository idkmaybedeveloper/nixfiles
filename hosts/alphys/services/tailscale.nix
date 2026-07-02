{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
  networking.firewall.checkReversePath = "loose";
}
