{ config, pkgs, abs, ... }:

{
  imports = [
    ./minecraft
    ./nginx
    ./tangled-knot
    (abs "services/tailscale-exit-node.nix")
  ];
}
