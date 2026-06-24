{
  config,
  lib,
  pkgs,
  abs,
  ...
}:

{
  imports = [
    ./AIM-server
    ./nginx
    ./cobalt
    ./legacymkch
    ./helium-services
    ./tangled-knot
    (abs "services/tailscale-exit-node.nix")
    ./nickel
    ./uran
  ];

  services.aim-oscar-server = {
    enable = true;
    configPath = "/etc/aos/settings.env";
    environment = { };
  };
}
