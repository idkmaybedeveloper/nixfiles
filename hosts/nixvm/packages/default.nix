# NOTE(kroot): recommended to keep in sync with playground1/packages/default.nix
{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./rules.nix
  ];
}