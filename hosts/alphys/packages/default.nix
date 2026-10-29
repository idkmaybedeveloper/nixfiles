{ config, pkgs, ... }:

{
  imports = [
    ./ida
    ./packages.nix
    ./rules.nix
    ./quirks.nix
  ];
}
