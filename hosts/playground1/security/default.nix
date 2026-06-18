{ config, pkgs, ... }:

{
  imports = [
    ./ping.nix
    ./acme.nix
  ];
}