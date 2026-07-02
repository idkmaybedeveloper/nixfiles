{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./rules.nix
    ./quirks.nix
  ];
}
