{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./rules.nix
  ];
}