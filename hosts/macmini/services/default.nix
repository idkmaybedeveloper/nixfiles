{ config, pkgs, ... }:

{
  imports = [
    ./mail.nix
    ./webmail.nix
    ./tailscale.nix
    ./nginx
    ./forgejo
    ./borrowd.nix
  ];
}
