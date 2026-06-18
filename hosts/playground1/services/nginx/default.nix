{config, lib, pkgs, ...}:
{
  imports = [ ./icq.nix  ./tangled-knot.nix ./cobalt.nix ./legacymkch.nix ./helium-services.nix ./nickel.nix ./uran.nix];
  services.nginx.package = pkgs.nginx; #NOTE(kroot): temp change to nginx, mb fixes bug with knot
}
